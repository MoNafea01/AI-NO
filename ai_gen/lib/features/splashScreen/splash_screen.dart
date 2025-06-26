import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/new_dashboard_screen.dart';
//import 'package:ai_gen/features/HomeScreen/home_screen.dart';
//import 'package:ai_gen/features/screens/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    _animationController.forward();
    loadServer();
  }

  void loadServer() async {
    // await GetIt.I.get<ServerManager>().startServer();

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Check if the widget is still mounted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            projectModel: widget.initialProject,
          ),
        ),
        // MaterialPageRoute(builder: (context) => const DashboardScreen()), // will go to signup screen
      );
    }
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Dispose the controller when the widget is removed
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
                  angle: _animation
                      .value, // Current rotation angle from the animation
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
