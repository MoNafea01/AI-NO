// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:ai_gen/core/data/network/server_manager/server_manager.dart';
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/screens/dashboard_screen.dart';
import 'package:ai_gen/features/auth/presentation/auth_screens/sign_in_screen.dart';
import 'package:ai_gen/features/auth/presentation/auth_screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.initialProject});

  final ProjectModel? initialProject;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _status = "Loading Server....";
  bool _showRetryButton = false;
  bool _isNavigating = false; // إضافة flag لمنع التنقل المتكرر

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
    _startServer();
  }

  Future<void> _startServer() async {
    if (_isNavigating) return; // منع إعادة التشغيل إذا كان التنقل قيد التنفيذ

    final serverManager = GetIt.I.get<ServerManager>();
    setState(() {
      _status = TranslationKeys.checkingServerStatus.tr;
      _showRetryButton = false;
    });

    try {
      bool running = await serverManager.isServerRunning();
      if (!running) {
        setState(() => _status = TranslationKeys.startingBackendServer.tr);

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

        // Poll until the server is up with shorter intervals
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

          if (mounted) {
            setState(
                () => _status = "Waiting for server to start... (${i + 1}/30)");
          }
        }
      }

      if (running) {
        setState(
            () => _status = TranslationKeys.serverRunningLoadingDashboard.tr);
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted && !_isNavigating) {
          _checkAuthentication();
        }
      } else {
        setState(() {
          _status = TranslationKeys.failedToStartServer;
          _showRetryButton = true;
        });
      }
    } catch (e) {
      log('Error during server startup: $e');
      if (mounted) {
        setState(() {
          _status = "Error starting server: ${e.toString()}";
          _showRetryButton = true;
        });
      }
    }
  }

  Future<void> _checkAuthentication() async {
    if (_isNavigating) return;

    _isNavigating = true;

    try {
      await Future.delayed(const Duration(seconds: 2)); // show splash effect

      if (!mounted) return;

      const FlutterSecureStorage secureStorage = FlutterSecureStorage();
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      final accessToken = await secureStorage.read(key: 'accessToken');
      final refreshToken = await secureStorage.read(key: 'refreshToken');

      if (!mounted) return;

      if (accessToken != null && refreshToken != null) {
        log("Navigating to DashboardScreen (already logged in)");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              projectModel: widget.initialProject,
            ),
          ),
        );
      } else if (isFirstTime) {
        await prefs.setBool('isFirstTime', false);
        log("Navigating to SignUpScreen (first time)");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      } else {
        log("Navigating to SignInScreen (returning user)");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      log('Error during authentication check: $e');
      if (mounted) {
        setState(() {
          _status = "Authentication error: ${e.toString()}";
          _showRetryButton = true;
          _isNavigating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              child: SvgPicture.asset(
                AssetsPaths.projectLogoIcon,
                width: 150,
                height: 150,
              ),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value,
                  child: child,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
            if (_showRetryButton && !_isNavigating) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _isNavigating = false;
                  _startServer();
                },
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
                child: Text(
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
