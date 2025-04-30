// Sidebar Widget
import 'package:flutter/material.dart';

import 'profile_section.dart';
import 'sidebar_icon.dart';
import 'sidebar_icon_app.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        color: Color(0xfff2f2f2),
        border: Border(
          right: BorderSide(color: Colors.black, width: 0.7),
          left: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: 20),
              SidebarIconApp(iconPath: "assets/images/ProjectLogo.png"),
              SizedBox(height: 20),
              SidebarIcon(icon: Icons.menu),
              SizedBox(height: 20),
              SidebarIcon(icon: Icons.dashboard),
              SidebarIcon(icon: Icons.search),
              SidebarIcon(icon: Icons.settings),
              SidebarIcon(icon: Icons.folder),
              SidebarIcon(icon: Icons.insert_chart),
            ],
          ),
          ProfileSection(),
        ],
      ),
    );
  }
}
