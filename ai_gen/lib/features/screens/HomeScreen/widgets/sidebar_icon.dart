// Sidebar Icon Widget
import 'package:flutter/material.dart';

class SidebarIcon extends StatelessWidget {
  final IconData icon;

  const SidebarIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: IconButton(
        icon: Icon(icon, color: const Color.fromARGB(255, 10, 10, 10)),
        onPressed: () {},
      ),
    );
  }
}
