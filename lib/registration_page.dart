import 'package:flutter/material.dart';
import 'package:chaanova/razorpay_web_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register for Enhance Educations", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Join Enhance Educations",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: nameController,
                        label: "Full Name",
                        icon: Icons.person,
                      ),
                      CustomTextField(
                        controller: emailController,
                        label: "Email Address",
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                      ),
                      CustomTextField(
                        controller: phoneController,
                        label: "Phone Number",
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone,
                      ),
                      Row(
                        children: [
                          Checkbox(
                              value: isWhatsAppSame,
                              onChanged: (value) => setState(() => isWhatsAppSame = value!)),
                          const Text("Same number for WhatsApp?"),
                        ],
                      ),
                      CustomDropdownField(
                        label: "State",
                        items: states,
                        onChanged: (val) => setState(() => selectedState = val),
                        icon: Icons.location_on,
                      ),
                      CustomTextField(
                        controller: learningGoalController,
                        label: "What do you want to improve?",
                        icon: Icons.school,
                      ),
                      TermsCheckbox(
                        isChecked: isTermsAccepted,
                        onChecked: (value) => _showTermsDialog(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 6,
                          ),
                          child: const Text(
                            "Register Now",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
        "service_id": "service_mhhx6il",  // Replace with EmailJS Service ID
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
      sendUserDetailsToEmail(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        wPhone: isWhatsAppSame ? phoneController.text : "",
        state: selectedState ?? "Unknown",
        improve: learningGoalController.text,
        paymentId: 'Started doing payment',
      );

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
          html.window.location.href = "http://enhanceeducations.com/";
        },
        onFailure: (error) {
          print("Payment Failed: $error");
          sendUserDetailsToEmail(
            name: nameController.text,
            email: emailController.text,
            phone: phoneController.text,
            wPhone: isWhatsAppSame ? phoneController.text : "",
            state: selectedState ?? "",
            improve: learningGoalController.text,
            paymentId: 'Payment failed',
          );
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
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple,) : null,
        ),
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? "Enter $label" : null,
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
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple,) : null,
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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

  const TermsCheckbox({required this.isChecked, required this.onChecked, super.key});

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
