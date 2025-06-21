// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:ai_gen/core/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/new_dashboard_screen.dart';

import 'package:ai_gen/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:http/http.dart' as storage; // Not used in this snippet, but keep if needed elsewhere
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//import '../HomeScreen/new_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller.
    // The duration here controls how long ONE rotation takes.
    // If you want it to spin for X seconds, set duration for one spin
    // and let the _checkAppStart delay handle the total display time.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Example: one spin takes 2 seconds
    );

    // Define the animation from 0 to 2*PI (a full circle rotation)
    _animation =
        Tween<double>(begin: 0, end: 2 * 3.14159).animate(_animationController);

    // Add a status listener to know when the animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation has completed its single run, now start navigation logic
        _checkAppStart();
      }
    });

    // Start the animation.
    // If you want it to spin multiple times within the 4-second splash,
    // you could use `_animationController.repeat(count: 2)` for two spins
    // or adjust the duration of _animationController relative to the _checkAppStart delay.
    _animationController.forward(); // Plays the animation once
  }

  Future<void> _checkAppStart() async {
    // This delay ensures the icon is shown for at least 4 seconds,
    // including the animation duration. If the animation is shorter,
    // the app will wait here until the 4 seconds are up before navigating.
    // If your animation takes longer than 4 seconds, navigation will
    // trigger only after _animationController.forward() finishes.
    await Future.delayed(const Duration(seconds: 2));

    // Ensure the widget is still mounted before attempting to navigate
    if (!mounted) return;

    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    final accessToken = await secureStorage.read(key: 'accessToken');
    final refreshToken = await secureStorage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      // User is already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      print("Navigating to DashboardScreen (already logged in)");
    } else if (isFirstTime) {
      // First-time user, go to sign-up and mark as not first time anymore
      await prefs.setBool('isFirstTime', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );
      print("Navigating to SignUpScreen (first time)");
    } else {
      // Returning user but logged out, go to sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      print("Navigating to LoginScreen (returning user)");
    }
  }

  @override
  void dispose() {
    // Dispose the animation controller to prevent memory leaks
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Or your desired splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation, // Listen to the animation for rebuilding
              child: SvgPicture.asset(
                // The widget that will be animated (your logo/icon)
                AssetsPaths.projectLogoIcon, // Your actual SVG asset path
                width: 150, // Adjust size as needed
                height: 150, // Adjust size as needed
              
              ),
              builder: (context, child) {
                // Apply the rotation transformation
                return Transform.rotate(
                  angle:
                      _animation.value, // Current rotation angle from the animation
                  child: child, // The SvgPicture.asset widget
                );
              },
            ),

            const SizedBox(height: 20), // Space between icon and text
            const Text(
              'Model Craft',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Adjust text color as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
