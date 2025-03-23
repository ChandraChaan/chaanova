import 'package:chaanova/user_view/dashboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chaanova/razorpay_web_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';

/// 🔹 **Registration Page**
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController learningGoalController = TextEditingController();

  String? selectedState;
  bool isWhatsAppSame = false, isTermsAccepted = false;

  final List<String> states = [
    "Andhra Pradesh",
    "Telangana",
    "Karnataka",
    "Tamil Nadu",
    "Maharashtra"
  ];

  Future<void> saveRegistrationDetails() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final learningGoal = learningGoalController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        selectedState == null ||
        !isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and accept the terms")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('registrations').add({
        'name': name,
        'email': email,
        'phone': phone,
        'learningGoal': learningGoal,
        'state': selectedState,
        'isWhatsAppSame': isWhatsAppSame,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Registration details saved!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save: \$e")),
      );
    }
  }

  final TextEditingController loginEmailController = TextEditingController();

  Future<void> checkLoginEmail() async {
    final email = loginEmailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Check if blocked
    final int? blockedUntil = prefs.getInt('loginBlockedUntil');
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (blockedUntil != null && now < blockedUntil) {
      final minutes = ((blockedUntil - now) / 60000).ceil();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("⏳ Too many failed attempts. Try again in $minutes min.")),
      );
      return;
    }

    try {
      final result = await FirebaseFirestore.instance
          .collection('registrations')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        // ✅ Match found
        await prefs.setBool('hasPaid', true);
        await prefs.remove('loginAttempts');
        await prefs.remove('loginBlockedUntil');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        // ❌ No match
        int attempts = prefs.getInt('loginAttempts') ?? 0;
        attempts += 1;
        await prefs.setInt('loginAttempts', attempts);

        if (attempts >= 3) {
          final blockTime = DateTime.now().add(const Duration(hours: 1));
          await prefs.setInt(
              'loginBlockedUntil', blockTime.millisecondsSinceEpoch);
          await prefs.setInt('loginAttempts', 0);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "🚫 Too many failed attempts. Try again after 1 hour.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("❌ Email not found. Attempts left: ${3 - attempts}")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enhance Educations",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              "Join Enhance Educations",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            controller: nameController,
                            label: "Full Name",
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: emailController,
                            label: "Email Address",
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: phoneController,
                            label: "Phone Number",
                            keyboardType: TextInputType.phone,
                            icon: Icons.phone,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: isWhatsAppSame,
                                onChanged: (value) => setState(() => isWhatsAppSame = value!),
                              ),
                              const Text("Same number for WhatsApp?"),
                            ],
                          ),
                          CustomDropdownField(
                            label: "State",
                            items: states,
                            onChanged: (val) => setState(() => selectedState = val),
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: learningGoalController,
                            label: "What do you want to improve?",
                            icon: Icons.school,
                          ),
                          const SizedBox(height: 12),
                          TermsCheckbox(
                            isChecked: isTermsAccepted,
                            onChecked: (value) => _showTermsDialog(),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text(
                              "Register Now",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              foregroundColor: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 36),
                          Divider(
                            height: 2,
                            color: Colors.grey.shade400,
                            thickness: 1,
                          ),
                          const SizedBox(height: 24),

                          Center(
                            child: Text(
                              "Already Registered?",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              labelText: "Enter your email to login",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: checkLoginEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade800,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms & Conditions"),
        content: const Text("By registering, you agree to our policies."),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => isTermsAccepted = true);
              Navigator.pop(context);
            },
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  void sendUserDetailsToEmail({
    required String name,
    required String email,
    required String phone,
    required String state,
    required String paymentId,
    required String wPhone,
    required String improve,
  }) async {
    const String apiUrl = "https://api.emailjs.com/api/v1.0/email/send";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "service_id": "service_mhhx6il", // Replace with EmailJS Service ID
        "template_id": "template_uzfcrln", // Replace with EmailJS Template ID
        "user_id": "qbZK7KCv2cWV2X0oW", // Replace with EmailJS User ID
        "template_params": {
          "name": name,
          "email": email,
          "phone": phone,
          "wPhone": wPhone,
          "improve": improve,
          "state": state,
          "paymentId": paymentId,
        }
      }),
    );

    if (response.statusCode == 200) {
      print("Email Sent Successfully!");
    } else {
      print("Failed to send email: ${response.body}");
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && isTermsAccepted) {
      saveRegistrationDetails();
      RazorpayWeb.openPayment(
        amount: 100.0,
        email: emailController.text,
        name: nameController.text,
        contact: phoneController.text,
        onSuccess: (paymentId) {
          sendUserDetailsToEmail(
            name: nameController.text,
            email: emailController.text,
            phone: phoneController.text,
            wPhone: isWhatsAppSame ? phoneController.text : "",
            state: selectedState ?? "",
            improve: learningGoalController.text,
            paymentId: paymentId,
          );

          print('payment done');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        },
        onFailure: (error) {
          print("Payment Failed: $error");
        },
      );
    }
  }
}

/// Custom Text Field Widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final IconData? icon;

  const CustomTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.deepPurple,
                )
              : null,
        ),
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? "Enter $label" : null,
      ),
    );
  }
}

/// Custom Dropdown Field Widget
class CustomDropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData? icon;

  const CustomDropdownField({
    required this.label,
    required this.items,
    required this.onChanged,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.deepPurple,
                )
              : null,
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Select $label" : null,
      ),
    );
  }
}

/// Terms Checkbox Widget
class TermsCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChecked;

  const TermsCheckbox(
      {required this.isChecked, required this.onChecked, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: isChecked, onChanged: onChecked),
        const Text("I accept the Terms & Conditions"),
      ],
    );
  }
}
