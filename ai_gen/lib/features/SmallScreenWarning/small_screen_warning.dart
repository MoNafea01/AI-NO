import 'package:flutter/material.dart';

class SmallScreenWarning extends StatelessWidget {
  const SmallScreenWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 140, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Screen size too small!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please maximize the window for a better experience.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Optionally close the app
                //Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}
