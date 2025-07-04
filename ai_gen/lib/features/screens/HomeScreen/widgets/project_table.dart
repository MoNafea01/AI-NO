
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class ProjectsTable extends StatefulWidget {
  const ProjectsTable({super.key});

  @override
  State<ProjectsTable> createState() => _ProjectsTableState();
}

class _ProjectsTableState extends State<ProjectsTable> {
  int currentPage = 1;
  final int itemsPerPage = 7;
  Set<int> selectedProjectIds = <int>{};
  bool isDeleting = false; // Track deletion state
  bool isDeletingEmpty = false; // Track empty projects deletion

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

    // Show loading indicator when deleting
    if (isDeleting || isDeletingEmpty) {
      return Container(
        width: double.infinity,
        height: 400, // Adjust height as needed
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
              const SizedBox(height: 16),
              Text(
                isDeletingEmpty
                    ? 'Deleting empty projects...'
                    : 'Deleting project...',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate pagination data
    final totalItems = homeState.projects.length;
    final totalPages = (totalItems / itemsPerPage).ceil();
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = math.min(startIndex + itemsPerPage, totalItems);
    final currentPageProjects =
        homeState.projects.sublist(startIndex, endIndex);

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
          // تعديل الهيدر لإضافة أزرار الحذف
          Container(
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
                      // زر تحديد/إلغاء تحديد الكل
                      Tooltip(
                        message: selectedProjectIds.isEmpty
                            ? "Select all projects"
                            : "Deselect all projects",
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
                            onTap: _toggleSelectAll,
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

                      // أزرار الحذف
                      if (selectedProjectIds.isNotEmpty) ...[
                        // زر حذف المحدد
                        Tooltip(
                          message:
                              "Delete selected projects (${selectedProjectIds.length})",
                          child: InkWell(
                            onTap: () => _showDeleteConfirmationDialog(
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

                      // زر حذف المشاريع الفارغة
                      Tooltip(
                        message:
                            "Delete all empty projects (projects with no model or dataset)",
                        child: InkWell(
                          onTap: _showDeleteEmptyProjectsDialog,
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

                      const Text(
                        "Name",
                        style: TextStyle(
                          fontFamily: AppConstants.appFontName,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_downward,
                        size: 12,
                        color: Color(0xFF666666),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    "Description",
                    style: TextStyle(
                      fontFamily: AppConstants.appFontName,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    "Dataset",
                    style: TextStyle(
                      fontFamily: AppConstants.appFontName,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    "Model",
                    style: TextStyle(
                      fontFamily: AppConstants.appFontName,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    "Created At",
                    style: TextStyle(
                      fontFamily: AppConstants.appFontName,
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
              itemCount: currentPageProjects.length,
              itemBuilder: (context, index) {
                final project = currentPageProjects[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              message: "Click to delete this project",
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: selectedProjectIds.contains(project.id)
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFFF5F5F5),
                                  border: Border.all(
                                    color:
                                        selectedProjectIds.contains(project.id)
                                            ? const Color(0xFF3B82F6)
                                            : const Color(0xFFD1D5DB),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: InkWell(
                                  onTap: () => _onProjectSelect(project.id),
                                  child: selectedProjectIds.contains(project.id)
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
                        child: _highlightSearchText(
                          project.description ?? "No description",
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
                        child: _buildDatasetCell(project.dataset),
                      ),
                      // Model column
                      Expanded(
                        flex: 2,
                        child: _buildModelCell(project.model),
                      ),
                      // Created At column
                      Expanded(
                        flex: 2,
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
                    ],
                  ),
                );
              },
            ),
          ),
          // Pagination Controls
          if (totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  InkWell(
                    onTap: currentPage > 1 ? _goToPreviousPage : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentPage > 1
                            ? Colors.white
                            : const Color(0xFFF9FAFB),
                        border: Border.all(
                          color: currentPage > 1
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_sharp,
                            size: 18,
                            color: currentPage > 1
                                ? const Color(0xFF374151)
                                : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Previous",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppConstants.appFontName,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: currentPage > 1
                                  ? const Color(0xFF374151)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Page Numbers
                  Row(
                    children: _buildPageNumbers(totalPages),
                  ),
                  // Next Button
                  InkWell(
                    onTap: currentPage < totalPages ? _goToNextPage : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentPage < totalPages
                            ? const Color(0xffFFFFFF)
                            : const Color(0xFFF9FAFB),
                        border: Border.all(
                          color: currentPage < totalPages
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Next",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppConstants.appFontName,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: currentPage < totalPages
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_sharp,
                            size: 18,
                            color: currentPage < totalPages
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatasetCell(String? dataset) {
    if (dataset == null || dataset.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          "No Dataset",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        dataset,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF1E40AF),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildModelCell(String? model) {
    if (model == null || model.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          "No Model",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        model,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF047857),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";

    // Format as: 27/06/2025 22:53
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pageNumbers = [];

    // Calculate which pages to show
    int startPage = math.max(1, currentPage - 2);
    int endPage = math.min(totalPages, currentPage + 2);

    // Adjust if we're near the beginning or end
    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = math.min(totalPages, startPage + 4);
      } else if (endPage == totalPages) {
        startPage = math.max(1, endPage - 4);
      }
    }

    // Add first page if not visible
    if (startPage > 1) {
      pageNumbers.add(_buildPageButton(1));
      if (startPage > 2) {
        pageNumbers.add(_buildEllipsis());
      }
    }

    // Add visible page numbers
    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(_buildPageButton(i));
    }

    // Add last page if not visible
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageNumbers.add(_buildEllipsis());
      }
      pageNumbers.add(_buildPageButton(totalPages));
    }

    return pageNumbers;
  }

  Widget _buildPageButton(int pageNumber) {
    final isCurrentPage = pageNumber == currentPage;

    return GestureDetector(
      onTap: () => _goToPage(pageNumber),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isCurrentPage ? const Color(0xFFCCCCCC) : const Color(0x0ff2f2f2),
          border: Border.all(
              color: isCurrentPage
                  ? const Color(0xFF666666)
                  : const Color.fromARGB(15, 181, 4, 4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isCurrentPage
                ? const Color(0xff1A1A1A)
                : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: const Text(
        "...",
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  void _goToNextPage() {
    HomeSuccess homeState = context.read<HomeCubit>().state as HomeSuccess;
    final totalPages = (homeState.projects.length / itemsPerPage).ceil();

    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _goToPage(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
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
          backgroundColor: Colors.yellow.shade100,
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
      text: TextSpan(
        children: spans,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Handle project selection
  // void _onProjectSelect(int? projectId) {
  //   if (projectId == null) return;

  //   if (selectedProjectIds.contains(projectId)) {
  //     // If already selected, show delete confirmation
  //     _showDeleteConfirmationDialog([projectId]);
  //   } else {
  //     // If not selected, add to selection
  //     setState(() {
  //       selectedProjectIds.add(projectId);
  //     });
  //   }
  // }

  // Show delete confirmation dialog for selected projects
  // void _showDeleteConfirmationDialog(List<int> projectIds) {
  //   final projectCount = projectIds.length;
  //   final projectText = projectCount == 1 ? 'project' : 'projects';

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           'Delete ${projectCount == 1 ? 'Project' : 'Projects'}',
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF374151),
  //           ),
  //         ),
  //         content: Text(
  //           'Are you sure you want to delete ${projectCount == 1 ? 'this' : 'these'} $projectText? This action cannot be undone.',
  //           style: const TextStyle(
  //             color: Color(0xFF6B7280),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               // Remove from selection if user cancels
  //               setState(() {
  //                 for (int id in projectIds) {
  //                   selectedProjectIds.remove(id);
  //                 }
  //               });
  //             },
  //             child: const Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: Color(0xFF6B7280),
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _deleteProjects(projectIds);
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFFDC2626),
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text('Delete'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Show delete empty projects confirmation dialog
  void _showDeleteEmptyProjectsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Empty Projects',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete all empty projects? This will remove all projects that have no model or dataset assigned. This action cannot be undone.',
            style: TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEmptyProjects();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Empty'),
            ),
          ],
        );
      },
    );
  }

  // Delete selected projects API call - FIXED WITH CORRECT BODY FORMAT
  Future<void> _deleteProjects(List<int> projectIds) async {
    try {
      // Set loading state
      setState(() {
        isDeleting = true;
      });

      // Debug logs
      print('Attempting to delete projects: $projectIds');

      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/projects/bulk-delete/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'projects_ids':
              projectIds, // Fixed: Changed from 'project_ids' to 'projects_ids'
        }),
      );

      // Debug logs
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - remove from selection
        setState(() {
          for (int id in projectIds) {
            selectedProjectIds.remove(id);
          }
        });

        // Show success message
        if (mounted) {
          final projectText = projectIds.length == 1 ? 'Project' : 'Projects';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$projectText deleted successfully'),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Refresh the projects list by calling the cubit method
        if (mounted) {
          await context.read<HomeCubit>().loadHomePage();
        }
      } else {
        // Error handling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to delete projects: ${response.statusCode}'),
              backgroundColor: const Color(0xFFDC2626),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Remove from selection on error
        setState(() {
          for (int id in projectIds) {
            selectedProjectIds.remove(id);
          }
        });
      }
    } catch (e) {
      // Network or other errors
      if (mounted) {
        print('Error deleting projects: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting projects: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Remove from selection on error
      setState(() {
        for (int id in projectIds) {
          selectedProjectIds.remove(id);
        }
      });
    } finally {
      // Always remove loading state
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  // Delete empty projects API call
  Future<void> _deleteEmptyProjects() async {
    try {
      // Set loading state
      setState(() {
        isDeletingEmpty = true;
      });

      // Debug logs
      print('Attempting to delete empty projects');

      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/projects/delete-empty-projects/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Debug logs
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empty projects deleted successfully'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Refresh the projects list by calling the cubit method
        if (mounted) {
          await context.read<HomeCubit>().loadHomePage();
        }
      } else {
        // Error handling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to delete empty projects: ${response.statusCode}'),
              backgroundColor: const Color(0xFFDC2626),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Network or other errors
      if (mounted) {
        print('Error deleting empty projects: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting empty projects: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Always remove loading state
      if (mounted) {
        setState(() {
          isDeletingEmpty = false;
        });
      }
    }
  }
  // تعديل دالة التحديد
  void _onProjectSelect(int? projectId) {
    if (projectId == null) return;

    setState(() {
      if (selectedProjectIds.contains(projectId)) {
        // إلغاء التحديد
        selectedProjectIds.remove(projectId);
      } else {
        // إضافة للتحديد
        selectedProjectIds.add(projectId);
      }
    });
  }

// دالة تحديد/إلغاء تحديد الكل
  void _toggleSelectAll() {
    setState(() {
      if (selectedProjectIds.isEmpty) {
        // تحديد جميع المشاريع في الصفحة الحالية
        final HomeSuccess homeState =
            context.read<HomeCubit>().state as HomeSuccess;
        final totalItems = homeState.projects.length;
        final startIndex = (currentPage - 1) * itemsPerPage;
        final endIndex = math.min(startIndex + itemsPerPage, totalItems);
        final currentPageProjects =
            homeState.projects.sublist(startIndex, endIndex);

        for (var project in currentPageProjects) {
          if (project.id != null) {
            selectedProjectIds.add(project.id!);
          }
        }
      } else {
        // إلغاء تحديد الكل
        selectedProjectIds.clear();
      }
    });
  }

// تحسين رسالة التأكيد
  void _showDeleteConfirmationDialog(List<int> projectIds) {
    final projectCount = projectIds.length;
    final projectText = projectCount == 1 ? 'project' : 'projects';

    // الحصول على أسماء المشاريع للعرض
    final HomeSuccess homeState =
        context.read<HomeCubit>().state as HomeSuccess;
    final selectedProjects = homeState.projects
        .where((project) => projectIds.contains(project.id))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete ${projectCount == 1 ? 'Project' : '$projectCount Projects'}',
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
                'Are you sure you want to delete ${projectCount == 1 ? 'this' : 'these'} $projectText? This action cannot be undone.',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
              if (projectCount <= 5) ...[
                const SizedBox(height: 12),
                const Text(
                  'Projects to be deleted:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                ...selectedProjects
                    .map((project) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  project.name ?? 'Unnamed Project',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProjects(projectIds);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child:
                  Text('Delete ${projectCount == 1 ? '' : '($projectCount)'}'),
            ),
          ],
        );
      },
    );
  }
}

