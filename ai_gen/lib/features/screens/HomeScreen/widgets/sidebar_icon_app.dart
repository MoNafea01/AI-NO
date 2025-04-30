// Sidebar Icon App Widget
import 'package:flutter/material.dart';

class SidebarIconApp extends StatelessWidget {
  final String iconPath;

  const SidebarIconApp({super.key, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        child: Image.asset(iconPath, height: 35, width: 35),
      ),
    );
  }
}
