import 'package:flutter/material.dart';

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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _progress = 0.0;
  int _elapsedTime = 0;
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    while (_progress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _elapsedTime += 100;
        _progress += 0.05;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (_progress < 1.0) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Loading Chaanova...",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  CircularProgressIndicator(value: _progress),
                  const SizedBox(height: 20),
                  Text("Elapsed Time: ${(_elapsedTime / 1000).toStringAsFixed(1)}s"),
                ],
              ),
            ),
          );
        } else {
          return const HomePage();
        }
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to Chaanova")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Chaanova - Learn, Register, and Pay Seamlessly",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Get Started"),
            ),
          ],
        ),
      ),
    );
  }
}