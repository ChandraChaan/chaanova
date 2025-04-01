import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../registration_page.dart';
import 'dashboard_page.dart';
import 'folder_page.dart';

class StartupChecker extends StatefulWidget {
  const StartupChecker({super.key});

  @override
  State<StartupChecker> createState() => _StartupCheckerState();
}

class _StartupCheckerState extends State<StartupChecker> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPaid = prefs.getBool('hasPaid') ?? false;

    if (hasPaid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FolderPage()),
      );
      return;
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
