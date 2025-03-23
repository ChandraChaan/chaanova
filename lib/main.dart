import 'package:chaanova/registration_page.dart';
import 'package:chaanova/user_view/dashboard_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

// Local Notification Plugin
final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

// Background & Terminated Message Handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showNotification(message.notification?.title, message.notification?.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // // Firebase Notification Setup
  // await _setupFirebaseMessaging();

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
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);
  localNotifications.initialize(settings);
}

/// 🔹 **Show Local Notifications**
void _showNotification(String? title, String? body) {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Chaanova Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);
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