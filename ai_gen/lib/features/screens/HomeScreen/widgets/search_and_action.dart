// Search and Actions Row Widget
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';

// Search and Actions Row Widget - Fixed Border Issue
import 'dart:async';

import 'package:ai_gen/core/utils/app_constants.dart';

import 'package:ai_gen/core/utils/helper/helper.dart';
import 'package:ai_gen/features/HomeScreen/cubit/home_cubit/home_cubit.dart';

import 'package:ai_gen/features/node_view/presentation/node_view.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'project_actions/import_project_dialog.dart';

class SearchAndActionsRow extends StatefulWidget {
  const SearchAndActionsRow({super.key, this.projectModel});

  final ProjectModel? projectModel;

  @override
  State<SearchAndActionsRow> createState() => _SearchAndActionsRowState();
}

class _SearchAndActionsRowState extends State<SearchAndActionsRow> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.projectModel != null) {
        // to trigger when oppening the project from the main args
        if (widget.projectModel?.id != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => NodeView(
                projectModel: widget.projectModel!,
              ),
            ),
          );
        } else {
          _triggerImport(context);
        }
      }
    });
  }

  void _triggerImport(BuildContext context) {
    Helper.showDialogHelper(
      context,
      ImportProjectDialog(
        cubit: context.read<HomeCubit>(),
        projectModel: widget.projectModel,
        outsourceProject: true,
      ),
    );
  }

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

              hintText: TranslationKeys.searchHint.tr,
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
<<<<<<< HEAD
          text: "Import",
          // icon: Icons.download,
          backgroundColor: const Color(0xfff2f2f2),
          textColor: AppColors.bluePrimaryColor,
          //  iconColor: AppColors.primaryColor,
          onTap: () {
            _triggerImport(context);
          },
          assetName: AssetsPaths.importIcon,
          iconColor: AppColors.bluePrimaryColor,
        ),
        CustomIconTextButton(
          assetName: AssetsPaths.exportIcon,
          text: "Export",
          //   icon: Icons.upload,
          backgroundColor: const Color(0xfff2f2f2),
          textColor: AppColors.bluePrimaryColor,
          //   iconColor: AppColors.primaryColor,
          onTap: () {
            Helper.showDialogHelper(context, const ExportProjectDialog());
          },
          iconColor: AppColors.bluePrimaryColor,
        ),
        CustomIconTextButton(
          text: "New Project",
          // icon: Icons.add,
          backgroundColor: AppColors.bluePrimaryColor,
          textColor: Colors.white,
          //  iconColor: Colors.white,
          onTap: () {
            Helper.showDialogHelper(context, const CreateNewProjectDialog());
=======
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
>>>>>>> dashboard_features
          },
        ),
        */
      ],
    );
  }
}
