import 'package:flutter/material.dart';

class FailureScreen extends StatelessWidget {
  const FailureScreen(this.errorMessage, {this.onRetry, super.key});

  final String errorMessage;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 36,
                ),
              ),
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
