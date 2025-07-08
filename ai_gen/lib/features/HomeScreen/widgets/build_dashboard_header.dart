import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/helper/helper.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/cubit/home_cubit/home_cubit.dart';
import 'package:ai_gen/features/HomeScreen/widgets/custom_icon_text_button.dart';
import 'package:ai_gen/features/HomeScreen/widgets/project_actions/create_new_project_dialog.dart';
import 'package:ai_gen/features/HomeScreen/widgets/project_actions/export_project_dialog.dart';
import 'package:ai_gen/features/HomeScreen/widgets/project_actions/import_project_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

Widget buildHeader(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 900;
      final isVerySmallScreen = constraints.maxWidth < 600;

      return SizedBox(
        width: double.infinity,
        child: Flex(
          direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: isSmallScreen
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          crossAxisAlignment: isSmallScreen
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            
            Flexible(
              flex: isSmallScreen ? 0 : 1,
              child: Padding(
                padding: EdgeInsets.only(
                  top: isSmallScreen ? 20 : 68,
                  bottom: isSmallScreen ? 20 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        TranslationKeys.projects.tr,
                        style: TextStyle(
                          fontFamily: AppConstants.appFontName,
                          fontSize: isVerySmallScreen
                              ? 32
                              : (isSmallScreen ? 36 : 48),
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        TranslationKeys.viewAllProjects.tr,
                        style: TextStyle(
                          fontFamily: AppConstants.appFontName,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff666666),
                          fontSize: isVerySmallScreen ? 12 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!isSmallScreen) const SizedBox(),

            Flexible(
              flex: isSmallScreen ? 0 : 1,
              child: _BuildActionButtons(
                isSmallScreen: isSmallScreen,
                isVerySmallScreen: isVerySmallScreen,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _BuildActionButtons extends StatelessWidget {
  final bool isSmallScreen;
  final bool isVerySmallScreen;

  const _BuildActionButtons({
    required this.isSmallScreen,
    required this.isVerySmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _buildButton(
        context: context,
        text: TranslationKeys.import.tr,
        backgroundColor: const Color(0xfff2f2f2),
        textColor: AppColors.bluePrimaryColor,
        assetName: AssetsPaths.importIcon,
        iconColor: AppColors.bluePrimaryColor,
        onTap: () {
          Helper.showDialogHelper(
            context,
            ImportProjectDialog(cubit: context.read<HomeCubit>()),
          );
        },
      ),
      _buildButton(
        context: context,
        text: TranslationKeys.export.tr,
        backgroundColor: const Color(0xfff2f2f2),
        textColor: AppColors.bluePrimaryColor,
        assetName: AssetsPaths.exportIcon,
        iconColor: AppColors.bluePrimaryColor,
        onTap: () {
          Helper.showDialogHelper(context, const ExportProjectDialog());
        },
      ),
      _buildButton(
        context: context,
        text: TranslationKeys.newProject.tr,
        backgroundColor: AppColors.bluePrimaryColor,
        textColor: Colors.white,
        assetName: AssetsPaths.addIcon,
        iconColor: Colors.white,
        onTap: () {
          Helper.showDialogHelper(context, const CreateNewProjectDialog());
        },
      ),
    ];

    if (isSmallScreen) {
      
      return isVerySmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buttons
                  .map((button) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: button,
                      ))
                  .toList(),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: buttons,
            );
    } else {
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: buttons
            .map((button) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: button,
                ))
            .toList(),
      );
    }
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required String assetName,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: isVerySmallScreen ? 0 : 60,
            maxWidth: isVerySmallScreen ? double.infinity : 140,
          ),
          child: CustomIconTextButton(
            text: text,
            backgroundColor: backgroundColor,
            textColor: textColor,
            assetName: assetName,
            iconColor: iconColor,
            onTap: onTap,
          ),
        );
      },
    );
  }
}
