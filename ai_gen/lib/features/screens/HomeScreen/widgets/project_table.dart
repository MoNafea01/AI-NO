// Enhanced Projects Table Widget with Pagination and Search Highlighting
import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

class ProjectsTable extends StatefulWidget {
  const ProjectsTable({super.key});

  @override
  State<ProjectsTable> createState() => _ProjectsTableState();
}

class _ProjectsTableState extends State<ProjectsTable> {
  int currentPage = 1;
  final int itemsPerPage = 7;

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
                          fontFamily: AppConstants.appFontName,
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
                      fontFamily: AppConstants.appFontName,
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
                      fontFamily: AppConstants.appFontName,
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
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
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
}
