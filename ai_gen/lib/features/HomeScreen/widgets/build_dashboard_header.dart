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
  return Row(
    // mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 68),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationKeys.projects.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              TranslationKeys.viewAllProjects.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontWeight: FontWeight.w500,
                color: Color(0xff666666),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      const Spacer(),
      CustomIconTextButton(
        text: TranslationKeys.import.tr,
        // icon: Icons.download,
        backgroundColor: const Color(0xfff2f2f2),
        textColor: AppColors.bluePrimaryColor,
        //  iconColor: AppColors.bluePrimaryColor,
        onTap: () {
          Helper.showDialogHelper(
            context,
            ImportProjectDialog(cubit: context.read<HomeCubit>()),
          );
        },
        assetName: AssetsPaths.importIcon,
        //

        iconColor: AppColors.bluePrimaryColor,
      ),
      CustomIconTextButton(
        assetName: AssetsPaths.exportIcon,
        //exportIcon

        text: TranslationKeys.export.tr,
        //   icon: Icons.upload,
        backgroundColor: const Color(0xfff2f2f2),
        textColor: AppColors.bluePrimaryColor,
        //   iconColor: AppColors.bluePrimaryColor,
        onTap: () {
          Helper.showDialogHelper(context, const ExportProjectDialog());
        },
        iconColor: AppColors.bluePrimaryColor,
      ),
      CustomIconTextButton(
        text: TranslationKeys.newProject.tr,
        // icon: Icons.add,
        backgroundColor: AppColors.bluePrimaryColor,
        textColor: Colors.white,
        //  iconColor: Colors.white,
        onTap: () {
          Helper.showDialogHelper(context, const CreateNewProjectDialog());
        },
        assetName: AssetsPaths.addIcon,
        iconColor: Colors.white,
      ),
    ],
  );
}
