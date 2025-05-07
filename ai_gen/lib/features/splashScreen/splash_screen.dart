import 'package:ai_gen/features/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/screens/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Check if the widget is still mounted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
         // MaterialPageRoute(builder: (context) => const DashboardScreen()), // will go to signup screen
        );
        // ignore: avoid_print
        print("Navigating to GridLoader...");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/ProjectLogo.png", height: 130),
            const SizedBox(height: 10),
            const Text("Model Craft",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
