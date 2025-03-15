import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

// Local Notification Plugin
final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

// Background & Terminated Message Handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showNotification(message.notification?.title, message.notification?.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Notification Setup
  await _setupFirebaseMessaging();

  runApp(const ChaanovaApp());
}

/// 🔹 **Setup Firebase Messaging & Local Notifications**
Future<void> _setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // Get Firebase Token
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Handle Foreground Notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("🔔 Foreground Notification: ${message.notification?.title}");
    _showNotification(message.notification?.title, message.notification?.body);
  });

  // Handle Background & Terminated State
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Local Notification Setup
  _setupLocalNotifications();
}

/// 🔹 **Setup Local Notifications**
void _setupLocalNotifications() {
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings settings = InitializationSettings(android: androidSettings);
  localNotifications.initialize(settings);
}

/// 🔹 **Show Local Notifications**
void _showNotification(String? title, String? body) {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', 'Chaanova Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
  localNotifications.show(0, title, body, platformDetails);
}

/// 🔹 **Chaanova App Entry Point**
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

  String? selectedState, selectedGender, preferredTiming, preferredMode, referralSource;
  bool isWhatsAppSame = false, isTermsAccepted = false;
  DateTime? selectedDateOfBirth;

  final List<String> states = ["Andhra Pradesh", "Telangana", "Karnataka", "Tamil Nadu", "Maharashtra"];
  final List<String> referralSources = ["Google", "YouTube", "Social Media", "Friend", "Other"];

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
                Text("Join Chaanova's English Improvement Classes", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                _buildTextField(nameController, "Full Name"),
                _buildTextField(emailController, "Email Address", keyboardType: TextInputType.emailAddress),
                _buildTextField(phoneController, "Phone Number", keyboardType: TextInputType.phone),
                Row(
                  children: [
                    Checkbox(value: isWhatsAppSame, onChanged: (value) => setState(() => isWhatsAppSame = value!)),
                    const Text("Same number for WhatsApp?"),
                  ],
                ),
                _buildDatePickerField(context),
                _buildDropdownField("Gender", ["Male", "Female", "Other"], (val) => selectedGender = val),
                _buildDropdownField("State", states, (val) => selectedState = val),
                _buildTextField(educationController, "Educational Background"),
                _buildTextField(learningGoalController, "What do you want to improve?"),
                _buildCheckboxWithDialog(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text("Register Now", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        // onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: const InputDecoration(labelText: "Date of Birth", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
            controller: TextEditingController(text: selectedDateOfBirth != null ? DateFormat("yyyy-MM-dd").format(selectedDateOfBirth!) : ""),
            validator: (value) => selectedDateOfBirth == null ? "Select your Date of Birth" : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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
          onChanged: (value) => value == true ? _showTermsDialog() : setState(() => isTermsAccepted = value!),
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

  void _submitForm() {
    if (_formKey.currentState!.validate() && isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful!")));
    }
  }
}