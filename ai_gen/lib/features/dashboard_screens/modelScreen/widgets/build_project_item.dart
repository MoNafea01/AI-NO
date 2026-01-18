import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildProjectItem(BuildContext context, ProjectModel project) {
  return InkWell(
    onTap: () {
      Navigator.of(context).pop(); // Close dialog first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NodeView(projectModel: project),
        ),
      );
    },
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffF2F2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xff999999)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Project Name
              Text(
                "${TranslationKeys.projectName.tr} : ${project.name ?? TranslationKeys.unnamedProject.tr}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff666666),
                ),
              ),

              /// Description
              if (project.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  "${TranslationKeys.projectDescription.tr} : ${project.description!}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff666666),
                    fontFamily: AppConstants.appFontName,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              /// Dataset
              if (project.dataset != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset(
                      AssetsPaths.dataSetsIcon,
                      color: AppColors.bluePrimaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${TranslationKeys.datasets.tr} : ${project.dataset}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        /// Created At - Top Right
        if (project.createdAt != null)
          Positioned(
            top: 8,
            right: 12,
            child: Text(
              "${TranslationKeys.created.tr} ${project.createdAt!.toString().split(' ')[0]}",
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );
}
