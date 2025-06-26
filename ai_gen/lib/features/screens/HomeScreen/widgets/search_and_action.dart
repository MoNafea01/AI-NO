// Search and Actions Row Widget - Fixed Border Issue
import 'dart:async';

import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/helper/helper.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:ai_gen/features/screens/HomeScreen/widgets/project_actions/export_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'custom_icon_text_button.dart';
import 'project_actions/create_new_project_dialog.dart';
import 'project_actions/import_project_dialog.dart';

class SearchAndActionsRow extends StatefulWidget {
  const SearchAndActionsRow({super.key});

  @override
  State<SearchAndActionsRow> createState() => _SearchAndActionsRowState();
}

class _SearchAndActionsRowState extends State<SearchAndActionsRow> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer for debouncing (wait 300ms after user stops typing)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<HomeCubit>().searchProjects(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        SizedBox(
          width: 300,
          height: 48,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              // Fixed: Added borderRadius to both enabledBorder and focusedBorder
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xff999999),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xff999999),
                  width: 1.5, // Slightly thicker when focused
                ),
              ),

              hintText: AppConstants.searchHint,
              hintStyle: const TextStyle(
                color: Color(0xff999999),
                fontFamily: AppConstants.appFontName,
                fontWeight: FontWeight.w700,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xff999999)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xff999999)),
                      onPressed: () {
                        _searchController.clear();
                        context.read<HomeCubit>().searchProjects('');
                        setState(() {}); // Rebuild to hide clear button
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xffF2F2F2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        // Add your other action buttons here
        // Example buttons (uncomment if needed):
        /*
        CustomIconTextButton(
          icon: Icons.add,
          text: 'New Project',
          onPressed: () {
            // Handle new project
          },
        ),
        CustomIconTextButton(
          icon: Icons.import_export,
          text: 'Import',
          onPressed: () {
            // Handle import
          },
        ),
        CustomIconTextButton(
          icon: Icons.file_download,
          text: 'Export',
          onPressed: () {
            // Handle export
          },
        ),
        */
      ],
    );
  }
}
