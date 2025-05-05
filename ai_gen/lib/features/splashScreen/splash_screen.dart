// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:ai_gen/features/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:ai_gen/features/screens/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as storage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    _checkAppStart();

  
  }

  Future<void> _checkAppStart() async {
    await Future.delayed(const Duration(seconds: 2)); // show splash effect
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    final accessToken = await secureStorage.read(key: 'accessToken');
    final refreshToken = await secureStorage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      // ✅ User is already logged in
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()));
      //MaterialPageRoute(builder: (context) => const DashboardScreen());
      //  Navigator.pushReplacementNamed(context, '/home');
      print("Navigating to HomeScreen (already logged in)");
    } else if (isFirstTime) {
      // ✅ First-time user, go to sign-up and mark as not first time anymore
      await prefs.setBool('isFirstTime', false);

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SignupScreen()));

      //MaterialPageRoute(builder: (context) => const SignupScreen());
      //  Navigator.pushReplacementNamed(context, '/signUp');
      print("Navigating to SignUpScreen (first time)");
    } else {
      // ✅ Returning user but logged out, go to sign-in

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
      // MaterialPageRoute(builder: (context) => const LoginScreen());

      //  Navigator.pushReplacementNamed(context, '/signIn');
      print("Navigating to SignInScreen (returning user)");
    }
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
