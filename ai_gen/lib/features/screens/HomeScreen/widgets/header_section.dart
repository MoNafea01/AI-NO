// Header Section Widget
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(
          "Projects",
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 14, 14, 14)),
        ),
        Text(
          "View all your projects.",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
}
