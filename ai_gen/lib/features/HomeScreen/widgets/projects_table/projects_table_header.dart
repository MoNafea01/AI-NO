import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/app_constants.dart';

class ProjectsTableHeader extends StatelessWidget {
  final Set<int> selectedProjectIds;
  final VoidCallback toggleSelectAll;
  final Function(List<int>) showDeleteConfirmationDialog;
  final VoidCallback showDeleteEmptyProjectsDialog;

  const ProjectsTableHeader({
    required this.selectedProjectIds, required this.toggleSelectAll, required this.showDeleteConfirmationDialog, required this.showDeleteEmptyProjectsDialog, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFE6E6E6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Select All / Deselect All Button
                Tooltip(
                  message: selectedProjectIds.isEmpty
                      ? TranslationKeys.selectAllProjects.tr
                      : TranslationKeys.deselectAllProjects.tr,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: selectedProjectIds.isEmpty
                          ? const Color(0xFFF5F5F5)
                          : const Color(0xFF3B82F6),
                      border: Border.all(
                        color: selectedProjectIds.isEmpty
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFF3B82F6),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: InkWell(
                      onTap: toggleSelectAll,
                      child: selectedProjectIds.isEmpty
                          ? null
                          : const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Delete Selected Button
                if (selectedProjectIds.isNotEmpty) ...[
                  Tooltip(
                    message:
                        "${TranslationKeys.deleteSelectedProjects.tr}(${selectedProjectIds.length})",
                    child: InkWell(
                      onTap: () => showDeleteConfirmationDialog(
                          selectedProjectIds.toList()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${selectedProjectIds.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Delete Empty Projects Button
                Tooltip(
                  message: TranslationKeys.deleteAllEmptyProjects.tr,
                  child: InkWell(
                    onTap: showDeleteEmptyProjectsDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.cleaning_services_outlined,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Text(
                  TranslationKeys.name.tr,
                  style: const TextStyle(
                    fontFamily: AppConstants.appFontName,
                    fontSize: 14.2,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_downward,
                  size: 16,
                  color: Color(0xFF666666),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              TranslationKeys.description.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              TranslationKeys.dataset.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              TranslationKeys.model.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              TranslationKeys.createdAt.tr,
              style: const TextStyle(
                fontFamily: AppConstants.appFontName,
                fontSize: 14.2,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
