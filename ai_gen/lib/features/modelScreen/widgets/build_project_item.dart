import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
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
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff999999)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name ?? TranslationKeys.unnamedProject.tr,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff666666)),
          ),
          if (project.description != null) ...[
            const SizedBox(height: 8),
            Text(
              project.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff666666),
                fontFamily: AppConstants.appFontName,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (project.dataset != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.dataset_outlined, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 4),
                Text(
                  '${TranslationKeys.datasets.tr} ${project.dataset}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ],
          if (project.createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              '${TranslationKeys.created.tr}${project.createdAt!.toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff666666),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
