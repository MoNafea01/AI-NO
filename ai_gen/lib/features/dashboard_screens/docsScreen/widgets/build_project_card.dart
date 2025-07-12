import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/widgets/build_tag.dart';
import 'package:ai_gen/features/dashboard_screens/docsScreen/widgets/copy_to_clip_board.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildProjectCard(ProjectModel project, BuildContext context) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: Color(0xff999999),
        width: 1,
      ),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NodeView(projectModel: project),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row - Project Name and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Name",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppConstants.appFontName,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.name ?? TranslationKeys.unnamedProject.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.appFontName,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (project.createdAt != null)
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          TranslationKeys.created.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppConstants.appFontName,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.createdAt!.toString().split(' ')[0],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontFamily: AppConstants.appFontName,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Description Section
            if (project.description != null &&
                project.description!.isNotEmpty) ...[
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppConstants.appFontName,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                project.description!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontFamily: AppConstants.appFontName,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
            ],

            // Model and Dataset Section
            if ((project.model != null && project.model!.isNotEmpty) ||
                (project.dataset != null && project.dataset!.isNotEmpty)) ...[
              Row(
                children: [
                  Text(
                    "Resources",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppConstants.appFontName,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (project.model != null && project.model!.isNotEmpty) ...[
                    Flexible(
                      child: buildTag(
                        icon: AssetsPaths.modelIcon,
                        label: project.model!,
                        color: Colors.blue,
                        onCopy: () => copyToClipboard(project.model!,
                            TranslationKeys.modelCopied.tr, context),
                      ),
                    ),
                    if (project.dataset != null && project.dataset!.isNotEmpty)
                      const SizedBox(width: 12),
                  ],
                  if (project.dataset != null &&
                      project.dataset!.isNotEmpty) ...[
                    Flexible(
                      child: buildTag(
                        icon: AssetsPaths.dataSetsIcon,
                        label: project.dataset!,
                        color: Colors.green,
                        onCopy: () => copyToClipboard(project.dataset!,
                            TranslationKeys.datasetCopied.tr, context),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Bottom spacing for visual balance
            const SizedBox(height: 4),
          ],
        ),
      ),
    ),
  );
}
