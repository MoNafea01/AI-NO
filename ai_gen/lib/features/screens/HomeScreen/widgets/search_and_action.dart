// Search and Actions Row Widget
import 'package:ai_gen/features/node_view/presentation/widgets/export_project_dialog.dart';
import 'package:flutter/material.dart';

import 'create_new_project_dialog.dart';
import 'custom_icon_text_button.dart';

class SearchAndActionsRow extends StatelessWidget {
  const SearchAndActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              hintText: "Search for projects",
              hintStyle: const TextStyle(color: Colors.black),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              filled: true,
              fillColor: const Color(0x00666666),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        CustomIconTextButton(
          text: "Import",
          icon: Icons.upload,
          backgroundColor: const Color(0xfff2f2f2),
          textColor: const Color.fromARGB(255, 15, 14, 14),
          iconColor: const Color.fromARGB(255, 7, 7, 7),
          onTap: () {},
        ),
        CustomIconTextButton(
          text: "Export",
          icon: Icons.download,
          backgroundColor: const Color(0xfff2f2f2),
          textColor: const Color.fromARGB(255, 15, 14, 14),
          iconColor: const Color.fromARGB(255, 7, 7, 7),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const Dialog(
                child: ExportProjectDialog(),
              ),
            );
          },
        ),
        CustomIconTextButton(
          text: "New Project",
          icon: Icons.add,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          iconColor: Colors.white,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const Dialog(
                child: CreateNewProjectDialog(),
              ),
            );
          },
        ),
      ],
    );
  }
}
