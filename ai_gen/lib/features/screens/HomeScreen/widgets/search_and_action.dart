// Search and Actions Row Widget
import 'package:ai_gen/core/utils/helper/helper.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:ai_gen/features/screens/HomeScreen/widgets/project_actions/export_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'custom_icon_text_button.dart';
import 'project_actions/create_new_project_dialog.dart';
import 'project_actions/import_project_dialog.dart';

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
          icon: Icons.download,
          backgroundColor: const Color(0xfff2f2f2),
          textColor: const Color.fromARGB(255, 15, 14, 14),
          iconColor: const Color.fromARGB(255, 7, 7, 7),
          onTap: () {
            Helper.showDialogHelper(
              context,
              ImportProjectDialog(cubit: context.read<HomeCubit>()),
            );
          },
        ),
        CustomIconTextButton(
          text: "Export",
          icon: Icons.upload,
          backgroundColor: const Color(0xfff2f2f2),
          textColor: const Color.fromARGB(255, 15, 14, 14),
          iconColor: const Color.fromARGB(255, 7, 7, 7),
          onTap: () {
            Helper.showDialogHelper(context, const ExportProjectDialog());
          },
        ),
        CustomIconTextButton(
          text: "New Project",
          icon: Icons.add,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          iconColor: Colors.white,
          onTap: () {
            Helper.showDialogHelper(context, const CreateNewProjectDialog());
          },
        ),
      ],
    );
  }
}

// shaltoot
Widget buildSearchBar(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 40,
          child: TextField(
            onChanged: (query) {
              
            },
            decoration: InputDecoration(
              hintText: 'Find a project',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon:
                  Icon(Icons.search, size: 20, color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
    ],
  );
}
