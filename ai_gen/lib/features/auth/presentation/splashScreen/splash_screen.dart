// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/network/server_manager/server_manager.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/screens/new_dashboard_screen.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:ai_gen/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.initialProject});

  final ProjectModel? initialProject;

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _status = "Loading Server....";
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _animationController = AnimationController(
      vsync: this, // Use 'this' as the TickerProvider
      duration: const Duration(seconds: 2), // Adjust duration as needed
    );

    // Initialize the Animation
    _animation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      // 2*pi for a full rotation
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Choose a suitable curve
      ),
    );
    _animationController.repeat(reverse: true);
    _startServer();
   // _checkAppStart();
  }

  Future<void> _startServer() async {
    final serverManager = GetIt.I.get<ServerManager>();
    setState(() {
      _status = TranslationKeys.checkingServerStatus.tr;
      _showRetryButton = false;
    });

    bool running = await serverManager.isServerRunning();
    if (!running) {
      setState(() => _status = TranslationKeys.startingBackendServer.tr);

      try {
        // Start the server script
        int exitCode = await serverManager.runAndListenToServerScript();

        // Handle different error scenarios
        if (exitCode != 0) {
          String errorMessage = serverManager.getErrorMessage(exitCode);

          setState(() {
            _status = errorMessage;
            _showRetryButton = true;
          });
          return;
        }

        // Now poll until the server is up with shorter intervals
        for (int i = 0; i < 30; i++) {
          await Future.delayed(const Duration(milliseconds: 500));

          // Check if the server process is still running
          if (!serverManager.isServerProcessRunning()) {
            setState(() {
              _status = TranslationKeys.serverStoppedUnexpectedly.tr;
              _showRetryButton = true;
            });
            return;
          }

          if (await serverManager.isServerRunning()) {
            running = true;
            break;
          }
          setState(
              () => _status = "Waiting for server to start... (${i + 1}/30)");
        }
      } catch (e) {
        log('Error during server startup: $e');
        setState(() {
          _status = "Error starting server: ${e.toString()}";
          _showRetryButton = true;
        });
        return;
      }
    }

    if (running) {
      setState(() => _status = TranslationKeys.serverRunningLoadingDashboard.tr);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
       _checkAppStart();
      }
    } else {
      setState(() {
        _status =
            TranslationKeys.failedToStartServer;
        _showRetryButton = true;
      });
    }
  }

 

  Future<void> _retryServer() async {
    await _startServer();
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

// check app start
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
      log("Navigating to HomeScreen (already logged in)");
    } else if (isFirstTime) {
      // ✅ First-time user, go to sign-up and mark as not first time anymore
      await prefs.setBool('isFirstTime', false);

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SignupScreen()));

      //MaterialPageRoute(builder: (context) => const SignupScreen());
      //  Navigator.pushReplacementNamed(context, '/signUp');
      log("Navigating to SignUpScreen (first time)");
    } else {
      // ✅ Returning user but logged out, go to sign-in

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
      // MaterialPageRoute(builder: (context) => const LoginScreen());

      //  Navigator.pushReplacementNamed(context, '/signIn');
      log("Navigating to SignInScreen (returning user)");
    }
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
                  angle: _animation
                      .value, // Current rotation angle from the animation
                  child: child, // The SvgPicture.asset widget
                );
              },
            ),

            const SizedBox(height: 20), // Space between icon and text
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Adjust text color as needed
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (_showRetryButton) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _retryServer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:  Text(
                  TranslationKeys.retry.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
