// Updated Projects Table Widget with Search Highlighting
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsTable extends StatelessWidget {
  const ProjectsTable({super.key});

  @override
  Widget build(BuildContext context) {
    HomeSuccess homeState = context.watch<HomeCubit>().state as HomeSuccess;

    if (homeState.projects.isEmpty) {
      return const Center(
        child: Text(
          "No Projects Found",
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE6E6E6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        "Name",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_downward,
                        size: 12,
                        color: Color(0xFF666666),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Created At",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Last Update",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: ListView.builder(
              itemCount: homeState.projects.length,
              itemBuilder: (context, index) {
                final project = homeState.projects[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
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
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFD1D5DB)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _projectName(context, project),
                                  if (project.description != null &&
                                      project.description!.isNotEmpty)
                                    _highlightSearchText(
                                      project.description!,
                                      context
                                          .read<HomeCubit>()
                                          .currentSearchQuery,
                                      const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Description column
                      Expanded(
                        flex: 2,
                        child: _highlightSearchText(
                          project.description ?? "",
                          context.read<HomeCubit>().currentSearchQuery,
                          const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                      // Created At column
                      Expanded(
                        flex: 1,
                        child: Text(
                          project.createdAt.toString().substring(0, 16),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Last Update column
                      Expanded(
                        flex: 1,
                        child: Text(
                          project.updatedAt.toString().substring(0, 16),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
      child: _highlightSearchText(
        project.name ?? "Project Name",
        context.read<HomeCubit>().currentSearchQuery,
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  
  Widget _highlightSearchText(
      String text, String searchQuery, TextStyle baseStyle) {
    if (searchQuery.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery.length),
        style: baseStyle.copyWith(
          backgroundColor: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + searchQuery.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans ,),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
