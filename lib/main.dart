import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


void main() {
  runApp(const ChaanovaApp());
}

class ChaanovaApp extends StatelessWidget {
  const ChaanovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chaanova',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegistrationPage(),
    );
  }
}


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

  String? selectedState;
  String? selectedGender;
  String? preferredMode;
  String? referralSource;
  bool isWhatsAppSame = false;
  bool isTermsAccepted = false;
  DateTime? selectedDateOfBirth;

  // List of States (Modify as needed)
  final List<String> states = [
    "Andhra Pradesh", "Telangana", "Karnataka", "Tamil Nadu", "Maharashtra"
  ];

  final List<String> learningModes = ["Live Classes", "Recorded Sessions"];
  final List<String> referralSources = ["Google", "YouTube", "Social Media", "Friend", "Other"];

  // Function to show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime firstDate = DateTime(today.year - 60, today.month, today.day);
    DateTime lastDate = DateTime(today.year - 10, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDateOfBirth) {
      setState(() {
        selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register for Chaanova")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Join Chaanova's English Improvement Classes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Full Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? "Enter your name" : null,
                ),
                const SizedBox(height: 12),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your email";
                    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Phone Number
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                  (value == null || value.length < 10) ? "Enter a valid phone number" : null,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isWhatsAppSame,
                      onChanged: (value) {
                        setState(() {
                          isWhatsAppSame = value!;
                        });
                      },
                    ),
                    const Text("Same number for WhatsApp?"),
                  ],
                ),
                const SizedBox(height: 12),

                // Date of Birth (Age)
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Date of Birth",
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: selectedDateOfBirth != null
                            ? DateFormat("yyyy-MM-dd").format(selectedDateOfBirth!)
                            : "",
                      ),
                      validator: (value) =>
                      selectedDateOfBirth == null ? "Select your Date of Birth" : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Gender
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                  ),
                  items: ["Male", "Female", "Other"].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  validator: (value) => value == null ? "Select your gender" : null,
                ),
                const SizedBox(height: 12),

                // State Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "State",
                    border: OutlineInputBorder(),
                  ),
                  items: states.map((state) {
                    return DropdownMenuItem(value: state, child: Text(state));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                  },
                  validator: (value) => value == null ? "Select your state" : null,
                ),
                const SizedBox(height: 12),

                // Terms & Conditions
                Row(
                  children: [
                    Checkbox(
                      value: isTermsAccepted,
                      onChanged: (value) {
                        setState(() {
                          isTermsAccepted = value!;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        _showTermsDialog(context);
                      },
                      child: const Text(
                        "I accept the Terms & Conditions",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && isTermsAccepted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Registration Successful!")),
                        );
                      }
                    },
                    child: const Text("Register Now"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Terms & Conditions"),
          content: const SingleChildScrollView(
            child: Text(
              "1. Your data will be securely stored and not shared.\n"
                  "2. Payments once made are non-refundable.\n"
                  "3. Chaanova reserves the right to modify class schedules.\n"
                  "4. Misuse of the platform will lead to account suspension.\n"
                  "5. By registering, you agree to our policies.",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Accept"),
            ),
          ],
        );
      },
    );
  }
}