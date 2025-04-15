import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Blue Left Panel
          Expanded(
            child: Container(
              color: Colors.blue[800],
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Spacer(),
                  Text(
                    'Join Model Craft Today',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Create an account and start bringing your models to life.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Spacer(),
                  // Add testimonial widget if needed
                ],
              ),
            ),
          ),

          // Right Panel - Form
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          //     child: SignUpForm(), // This will be our next step
          //   ),
          // ),
        ],
      ),
    );
  }
}
