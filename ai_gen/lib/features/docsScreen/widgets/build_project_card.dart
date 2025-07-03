
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/features/docsScreen/widgets/build_tag.dart';
import 'package:ai_gen/features/docsScreen/widgets/copy_to_clip_board.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildProjectCard(ProjectModel project , BuildContext context) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name
            Text(
              project.name ?? TranslationKeys.unnamedProject.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: AppConstants.appFontName,
              ),
            ),

            // Description
            if (project.description != null &&
                project.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                project.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: AppConstants.appFontName,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Model and Dataset Tags
            Row(
              children: [
                if (project.model != null && project.model!.isNotEmpty) ...[
                  buildTag(
                    icon: Icons.model_training,
                    label: project.model!,
                    color: Colors.blue,
                    onCopy: () => copyToClipboard(
                        project.model!, TranslationKeys.modelCopied.tr , context),
                  ),
                  const SizedBox(width: 8),
                ],
                if (project.dataset != null && project.dataset!.isNotEmpty) ...[
                  buildTag(
                    icon: Icons.dataset_outlined,
                    label: project.dataset!,
                    color: Colors.green,
                    onCopy: () => copyToClipboard(
                        project.dataset!, TranslationKeys.datasetCopied.tr, context),
                  ),
                ],
              ],
            ),

            // Created Date
            if (project.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                '${TranslationKeys.created.tr}: ${project.createdAt!.toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontFamily: AppConstants.appFontName,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
