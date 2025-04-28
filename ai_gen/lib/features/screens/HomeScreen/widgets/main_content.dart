// Main Content Widget
import 'package:flutter/material.dart';

import 'header_section.dart';
import 'project_table.dart';
import 'search_and_action.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 65, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          HeaderSection(),
          SearchAndActionsRow(),
          Expanded(child: ProjectsTable()),
        ],
      ),
    );
  }
}
