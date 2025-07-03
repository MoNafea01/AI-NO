import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final List<int> projectIds;
  final List<String> projectNames;
  final Function(List<int>) onConfirm;

  const DeleteConfirmationDialog({
    required this.projectIds,
    required this.projectNames,
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final projectCount = projectIds.length;
    final projectText = projectCount == 1
        ? TranslationKeys.project.tr
        : TranslationKeys.projects.tr;

    return AlertDialog(
      backgroundColor: const Color(0xffF2F2F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        '${TranslationKeys.deleteButton.tr} ${projectCount == 1 ? TranslationKeys.project.tr : '$projectCount ${TranslationKeys.projects.tr}'}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TranslationKeys.areYouSure.tr}${projectCount == 1 ? TranslationKeys.thisTitle.tr : TranslationKeys.theseTitle.tr} $projectText${TranslationKeys.questionMark.tr}${TranslationKeys.thisActionCannotBeUndone.tr}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
          if (projectCount <= 5) ...[
            const SizedBox(height: 12),
            Text(
              TranslationKeys.projectsToBeDeleted.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            ...projectNames.map((name) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xff666666),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xff666666),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bluePrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            TranslationKeys.cancel.tr,
            style: const TextStyle(
                // color: Color(0xff666666),
                ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm(projectIds);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
              '${TranslationKeys.deleteButton.tr} ${projectCount == 1 ? '' : '($projectCount)'}'),
        ),
      ],
    );
  }
}
