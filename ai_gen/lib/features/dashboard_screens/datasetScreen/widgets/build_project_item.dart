import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';

import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';

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
                'Project name: ${project.name ?? 'Unnamed Project'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff666666),
                  fontFamily: AppConstants.appFontName,
                ),
              ),

              /// Project Description
              if (project.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Project description: ${project.description!}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff666666),
                    fontFamily: AppConstants.appFontName,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              /// Model badge
              if (project.model != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bluePrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AssetsPaths.modelIcon,
                        color: AppColors.white,
                        width: 19,
                        height: 19,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.model!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        /// Created At (Top Right)
        if (project.createdAt != null)
          Positioned(
            top: 8,
            right: 12,
            child: Text(
              'Created: ${project.createdAt!.toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff666666),
                fontFamily: AppConstants.appFontName,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );
}
