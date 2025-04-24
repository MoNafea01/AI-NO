import 'package:flutter/material.dart';

import 'widgets/main_content.dart';
import 'widgets/side_bar_widget.dart';

class ProjectsDashboard extends StatelessWidget {
  const ProjectsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: Row(
        children: [
          Sidebar(),
          Expanded(child: MainContent()),
        ],
      ),
    );
  }
}
