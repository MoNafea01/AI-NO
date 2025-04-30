// Profile Section Widget
import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Profile",
          style: TextStyle(color: Color(0xff64748B), fontSize: 16),
        ),
        const SizedBox(height: 10),
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage("assets/images/profileImage.png"),
        ),
        const SizedBox(height: 10),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
