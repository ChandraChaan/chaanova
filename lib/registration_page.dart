import 'package:flutter/material.dart';
import 'package:chaanova/razorpay_web_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
  final TextEditingController educationController = TextEditingController();
  final TextEditingController learningGoalController = TextEditingController();

  String? selectedState,
      selectedGender,
      preferredTiming,
      preferredMode,
      referralSource;
  bool isWhatsAppSame = false, isTermsAccepted = false;
  DateTime? selectedDateOfBirth;

  final List<String> states = [
    "Andhra Pradesh",
    "Telangana",
    "Karnataka",
    "Tamil Nadu",
    "Maharashtra"
  ];
  final List<String> referralSources = [
    "Google",
    "YouTube",
    "Social Media",
    "Friend",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register for Chaanova")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Join Chaanova's English Improvement Classes",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                _buildTextField(nameController, "Full Name"),
                _buildTextField(emailController, "Email Address",
                    keyboardType: TextInputType.emailAddress),
                _buildTextField(phoneController, "Phone Number",
                    keyboardType: TextInputType.phone),
                Row(
                  children: [
                    Checkbox(
                        value: isWhatsAppSame,
                        onChanged: (value) =>
                            setState(() => isWhatsAppSame = value!)),
                    const Text("Same number for WhatsApp?"),
                  ],
                ),
                _buildDropdownField(
                    "State", states, (val) => selectedState = val),
                _buildTextField(
                    learningGoalController, "What do you want to improve?"),
                _buildCheckboxWithDialog(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text("Register Now",
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration:
        InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: keyboardType,
        validator: (value) =>
        value == null || value.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration:
        InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) => setState(() => onChanged(value)),
        validator: (value) => value == null ? "Select $label" : null,
      ),
    );
  }

  Widget _buildCheckboxWithDialog() {
    return Row(
      children: [
        Checkbox(
          value: isTermsAccepted,
          onChanged: (value) => value == true
              ? _showTermsDialog()
              : setState(() => isTermsAccepted = value!),
        ),
        const Text("I accept the Terms & Conditions"),
      ],
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
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

      RazorpayWeb.openPayment(
        amount: 100.0,
        email: emailController.text,
        name: nameController.text,
        contact: phoneController.text,
        onSuccess: (paymentId) {
          print("Payment Successful! ID: $paymentId");
          sendUserDetailsToEmail(
            name: nameController.text,
            email: emailController.text,
            phone: phoneController.text,
            wPhone: isWhatsAppSame ? phoneController.text: "",
            state: selectedState ?? "",
            improve: learningGoalController.text,
            paymentId: 'paymentId',
          );
        },
        onFailure: (error) {
          print("Payment Failed: $error");
        },
      );


    }
  }
}