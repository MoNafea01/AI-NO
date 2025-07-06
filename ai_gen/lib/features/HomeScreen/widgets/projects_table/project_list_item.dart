
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/features/HomeScreen/cubit/home_cubit/home_cubit.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../../core/models/project_model.dart';

import 'project_cells.dart'; // Contains _buildDatasetCell, _buildModelCell, _highlightSearchText

class ProjectListItem extends StatelessWidget {
  final ProjectModel project;
  final bool isSelected;
  final Function(int?) onSelect;

  const ProjectListItem({
    required this.project,
    required this.isSelected,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64, // perfect height
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFCCCCCC),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Name column with checkbox
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Tooltip(
                  message: isSelected
                      ? TranslationKeys.undoSelectionTitle.tr
                      : TranslationKeys.doYouWantToDelete.tr,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFF5F5F5),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFD1D5DB),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: InkWell(
                      onTap: () => onSelect(project.id),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _projectName(context, project),
                ),
              ],
            ),
          ),
          // Description column
          Expanded(
            flex: 2,
            child: highlightSearchText(
              project.description ?? TranslationKeys.noDescriptionTitle.tr,
              context.read<HomeCubit>().currentSearchQuery,
              
              const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
          // Dataset column
          Expanded(
            flex: 2,
            child: buildDatasetCell(project.dataset),
          ),
          // Model column
          Expanded(
            flex: 2,
            child: buildModelCell(project.model),
          ),
          // Created At column - Moved to the left
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 8), // Reduced padding to move left
              child: Text(
                _formatDateTime(project.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to NodeView for the project
  Widget _projectName(BuildContext context, ProjectModel project) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NodeView(projectModel: project),
          ),
        );
      },
      child: highlightSearchText(
        project.name ?? TranslationKeys.projectName.tr,
        context.read<HomeCubit>().currentSearchQuery,
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  // Helper to format DateTime
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return TranslationKeys.na.tr;

    // List of month names
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return "${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}";
  }
}
