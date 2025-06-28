// // Enhanced Projects Table Widget with Pagination and Search Highlighting
// import 'package:ai_gen/core/models/project_model.dart';
// import 'package:ai_gen/core/utils/app_constants.dart';
// import 'package:ai_gen/core/utils/themes/app_colors.dart';
// import 'package:ai_gen/features/node_view/presentation/node_view.dart';
// import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math' as math;

// class ProjectsTable extends StatefulWidget {
//   const ProjectsTable({super.key});

//   @override
//   State<ProjectsTable> createState() => _ProjectsTableState();
// }

// class _ProjectsTableState extends State<ProjectsTable> {
//   int currentPage = 1;
//   final int itemsPerPage = 7;
//   Set<int> selectedProjectIds = <int>{};

//   @override
//   Widget build(BuildContext context) {
//     HomeSuccess homeState = context.watch<HomeCubit>().state as HomeSuccess;

//     if (homeState.projects.isEmpty) {
//       return const Center(
//         child: Text(
//           "No Projects Found",
//           style: TextStyle(fontSize: 20),
//         ),
//       );
//     }

//     // Calculate pagination data
//     final totalItems = homeState.projects.length;
//     final totalPages = (totalItems / itemsPerPage).ceil();
//     final startIndex = (currentPage - 1) * itemsPerPage;
//     final endIndex = math.min(startIndex + itemsPerPage, totalItems);
//     final currentPageProjects =
//         homeState.projects.sublist(startIndex, endIndex);

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               color: Color(0xFFE6E6E6),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(8),
//                 topRight: Radius.circular(8),
//               ),
//             ),
//             child: const Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Row(
//                     children: [
//                       Text(
//                         "Name",
//                         style: TextStyle(
//                           fontFamily: AppConstants.appFontName,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF666666),
//                         ),
//                       ),
//                       SizedBox(width: 4),
//                       Icon(
//                         Icons.arrow_downward,
//                         size: 12,
//                         color: Color(0xFF666666),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     "Description",
//                     style: TextStyle(
//                       fontFamily: AppConstants.appFontName,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     "Dataset",
//                     style: TextStyle(
//                       fontFamily: AppConstants.appFontName,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     "Model",
//                     style: TextStyle(
//                       fontFamily: AppConstants.appFontName,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     "Created At",
//                     style: TextStyle(
//                       fontFamily: AppConstants.appFontName,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF666666),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Body
//           Expanded(
//             child: ListView.builder(
//               itemCount: currentPageProjects.length,
//               itemBuilder: (context, index) {
//                 final project = currentPageProjects[index];
//                 return Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFF5F5F5),
//                     border: Border(
//                       bottom: BorderSide(
//                         color: Color(0xFFCCCCCC),
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       // Name column with checkbox
//                       Expanded(
//                         flex: 3,
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 16,
//                               height: 16,
//                               decoration: BoxDecoration(
//                                 color: selectedProjectIds.contains(project.id)
//                                     ? const Color(0xFF3B82F6)
//                                     : const Color(0xFFF5F5F5),
//                                 border: Border.all(
//                                   color: selectedProjectIds.contains(project.id)
//                                       ? const Color(0xFF3B82F6)
//                                       : const Color(0xFFD1D5DB),
//                                 ),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: InkWell(
//                                 onTap: () => _onProjectSelect(project.id),
//                                 child: selectedProjectIds.contains(project.id)
//                                     ? const Icon(
//                                         Icons.check,
//                                         size: 12,
//                                         color: Colors.white,
//                                       )
//                                     : null,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: _projectName(context, project),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Description column
//                       Expanded(
//                         flex: 2,
//                         child: _highlightSearchText(
//                           project.description ?? "No description",
//                           context.read<HomeCubit>().currentSearchQuery,
//                           const TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF374151),
//                           ),
//                         ),
//                       ),
//                       // Dataset column
//                       Expanded(
//                         flex: 2,
//                         child: _buildDatasetCell(project.dataset),
//                       ),
//                       // Model column
//                       Expanded(
//                         flex: 2,
//                         child: _buildModelCell(project.model),
//                       ),
//                       // Created At column
//                       Expanded(
//                         flex: 2,
//                         child: Text(
//                           _formatDateTime(project.createdAt),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF6B7280),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//           // Pagination Controls
//           if (totalPages > 1)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: const BoxDecoration(
//                 color: Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(8),
//                   bottomRight: Radius.circular(8),
//                 ),
//                 border: Border(
//                   top: BorderSide(
//                     color: Color(0xFFE5E7EB),
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Previous Button
//                   InkWell(
//                     onTap: currentPage > 1 ? _goToPreviousPage : null,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: currentPage > 1
//                             ? Colors.white
//                             : const Color(0xFFF9FAFB),
//                         border: Border.all(
//                           color: currentPage > 1
//                               ? const Color(0xFFD1D5DB)
//                               : const Color(0xFFE5E7EB),
//                         ),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.arrow_back_sharp,
//                             size: 18,
//                             color: currentPage > 1
//                                 ? const Color(0xFF374151)
//                                 : const Color(0xFF9CA3AF),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             "Previous",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontFamily: AppConstants.appFontName,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: currentPage > 1
//                                   ? const Color(0xFF374151)
//                                   : const Color(0xFF9CA3AF),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Page Numbers
//                   Row(
//                     children: _buildPageNumbers(totalPages),
//                   ),
//                   // Next Button
//                   InkWell(
//                     onTap: currentPage < totalPages ? _goToNextPage : null,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: currentPage < totalPages
//                             ? const Color(0xffFFFFFF)
//                             : const Color(0xFFF9FAFB),
//                         border: Border.all(
//                           color: currentPage < totalPages
//                               ? const Color(0xFFD1D5DB)
//                               : const Color(0xFFE5E7EB),
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             "Next",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontFamily: AppConstants.appFontName,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: currentPage < totalPages
//                                   ? const Color(0xFF1A1A1A)
//                                   : const Color(0xFF9CA3AF),
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Icon(
//                             Icons.arrow_forward_sharp,
//                             size: 18,
//                             color: currentPage < totalPages
//                                 ? const Color(0xFF1A1A1A)
//                                 : const Color(0xFF9CA3AF),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDatasetCell(String? dataset) {
//     if (dataset == null || dataset.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(4),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: const Text(
//           "No Dataset",
//           style: TextStyle(
//             fontSize: 12,
//             color: Color(0xFF9CA3AF),
//             fontStyle: FontStyle.italic,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Text(
//         dataset,
//         style: const TextStyle(
//           fontSize: 12,
//           color: Color(0xFF1E40AF),
//           fontWeight: FontWeight.w500,
//         ),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildModelCell(String? model) {
//     if (model == null || model.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(4),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: const Text(
//           "No Model",
//           style: TextStyle(
//             fontSize: 12,
//             color: Color(0xFF9CA3AF),
//             fontStyle: FontStyle.italic,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.green.shade50,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: Colors.green.shade200),
//       ),
//       child: Text(
//         model,
//         style: const TextStyle(
//           fontSize: 12,
//           color: Color(0xFF047857),
//           fontWeight: FontWeight.w500,
//         ),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   String _formatDateTime(DateTime? dateTime) {
//     if (dateTime == null) return "N/A";

//     // Format as: 27/06/2025 22:53
//     return "${dateTime.day.toString().padLeft(2, '0')}/"
//         "${dateTime.month.toString().padLeft(2, '0')}/"
//         "${dateTime.year} "
//         "${dateTime.hour.toString().padLeft(2, '0')}:"
//         "${dateTime.minute.toString().padLeft(2, '0')}";
//   }

//   List<Widget> _buildPageNumbers(int totalPages) {
//     List<Widget> pageNumbers = [];

//     // Calculate which pages to show
//     int startPage = math.max(1, currentPage - 2);
//     int endPage = math.min(totalPages, currentPage + 2);

//     // Adjust if we're near the beginning or end
//     if (endPage - startPage < 4) {
//       if (startPage == 1) {
//         endPage = math.min(totalPages, startPage + 4);
//       } else if (endPage == totalPages) {
//         startPage = math.max(1, endPage - 4);
//       }
//     }

//     // Add first page if not visible
//     if (startPage > 1) {
//       pageNumbers.add(_buildPageButton(1));
//       if (startPage > 2) {
//         pageNumbers.add(_buildEllipsis());
//       }
//     }

//     // Add visible page numbers
//     for (int i = startPage; i <= endPage; i++) {
//       pageNumbers.add(_buildPageButton(i));
//     }

//     // Add last page if not visible
//     if (endPage < totalPages) {
//       if (endPage < totalPages - 1) {
//         pageNumbers.add(_buildEllipsis());
//       }
//       pageNumbers.add(_buildPageButton(totalPages));
//     }

//     return pageNumbers;
//   }

//   Widget _buildPageButton(int pageNumber) {
//     final isCurrentPage = pageNumber == currentPage;

//     return GestureDetector(
//       onTap: () => _goToPage(pageNumber),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 2),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color:
//               isCurrentPage ? const Color(0xFFCCCCCC) : const Color(0x0ff2f2f2),
//           border: Border.all(
//               color: isCurrentPage
//                   ? const Color(0xFF666666)
//                   : const Color.fromARGB(15, 181, 4, 4)),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           pageNumber.toString(),
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: isCurrentPage
//                 ? const Color(0xff1A1A1A)
//                 : const Color(0xFF666666),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEllipsis() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 2),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       child: const Text(
//         "...",
//         style: TextStyle(
//           fontSize: 14,
//           color: Color(0xFF9CA3AF),
//         ),
//       ),
//     );
//   }

//   void _goToPreviousPage() {
//     if (currentPage > 1) {
//       setState(() {
//         currentPage--;
//       });
//     }
//   }

//   void _goToNextPage() {
//     HomeSuccess homeState = context.read<HomeCubit>().state as HomeSuccess;
//     final totalPages = (homeState.projects.length / itemsPerPage).ceil();

//     if (currentPage < totalPages) {
//       setState(() {
//         currentPage++;
//       });
//     }
//   }

//   void _goToPage(int pageNumber) {
//     setState(() {
//       currentPage = pageNumber;
//     });
//   }

//   Widget _projectName(BuildContext context, ProjectModel project) {
//     return InkWell(
//       onTap: () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => NodeView(projectModel: project),
//           ),
//         );
//       },
//       child: _highlightSearchText(
//         project.name ?? "Project Name",
//         context.read<HomeCubit>().currentSearchQuery,
//         const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//           color: Color(0xFF111827),
//         ),
//       ),
//     );
//   }

//   Widget _highlightSearchText(
//       String text, String searchQuery, TextStyle baseStyle) {
//     if (searchQuery.isEmpty || text.isEmpty) {
//       return Text(
//         text,
//         style: baseStyle,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//       );
//     }

//     final List<TextSpan> spans = [];
//     final String lowerText = text.toLowerCase();
//     final String lowerQuery = searchQuery.toLowerCase();

//     int start = 0;
//     int index = lowerText.indexOf(lowerQuery);

//     while (index != -1) {
//       // Add text before match
//       if (index > start) {
//         spans.add(TextSpan(
//           text: text.substring(start, index),
//           style: baseStyle,
//         ));
//       }

//       // Add highlighted match
//       spans.add(TextSpan(
//         text: text.substring(index, index + searchQuery.length),
//         style: baseStyle.copyWith(
//           backgroundColor: Colors.yellow.shade100,
//           fontWeight: FontWeight.bold,
//         ),
//       ));

//       start = index + searchQuery.length;
//       index = lowerText.indexOf(lowerQuery, start);
//     }

//     // Add remaining text
//     if (start < text.length) {
//       spans.add(TextSpan(
//         text: text.substring(start),
//         style: baseStyle,
//       ));
//     }

//     return RichText(
//       text: TextSpan(
//         children: spans,
//       ),
//       maxLines: 2,
//       overflow: TextOverflow.ellipsis,
//     );
//   }

//   // Handle project selection
//   void _onProjectSelect(int? projectId) {
//     if (projectId == null) return;

//     if (selectedProjectIds.contains(projectId)) {
//       // If already selected, show delete confirmation
//       _showDeleteConfirmationDialog(projectId);
//     } else {
//       // If not selected, add to selection
//       setState(() {
//         selectedProjectIds.add(projectId);
//       });
//     }
//   }

//   // Show delete confirmation dialog
//   void _showDeleteConfirmationDialog(int projectId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'Delete Project',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF374151),
//             ),
//           ),
//           content: const Text(
//             'Are you sure you want to delete this project? This action cannot be undone.',
//             style: TextStyle(
//               color: Color(0xFF6B7280),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Remove from selection if user cancels
//                 setState(() {
//                   selectedProjectIds.remove(projectId);
//                 });
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   color: Color(0xFF6B7280),
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _deleteProject(projectId);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFDC2626),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Delete project API call - UPDATED TO USE DELETE METHOD
//   Future<void> _deleteProject(int projectId) async {
//     try {
//       // Debug logs
//       print('Attempting to delete project: $projectId');

//       final response = await http.delete(
//         // Changed from http.post to http.delete
//         Uri.parse('http://127.0.0.1:8000/api/projects/bulk-delete/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode({
//           'projects_ids': [projectId],
//         }),
//       );

//       // Debug logs
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//       print('Response headers: ${response.headers}');

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         // Success - remove from selection and refresh the list
//         setState(() {
//           selectedProjectIds.remove(projectId);
//         });

//         // Show success message
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Project deleted successfully'),
//               backgroundColor: Color(0xFF10B981),
//               duration: Duration(seconds: 2),
//             ),
//           );
//         }

//         // Refresh the projects list - uncomment if you have this method
//         // context.read<HomeCubit>().loadProjects();
//       } else {
//         // Error handling
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to delete project: ${response.statusCode}'),
//               backgroundColor: const Color(0xFFDC2626),
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }

//         // Remove from selection on error
//         setState(() {
//           selectedProjectIds.remove(projectId);
//         });
//       }
//     } catch (e) {
//       // Network or other errors
//       if (mounted) {
//         print('Error deleting project: $e');
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error deleting project: $e'),
//             backgroundColor: const Color(0xFFDC2626),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }

//       // Remove from selection on error
//       setState(() {
//         selectedProjectIds.remove(projectId);
//       });
//     }
//   }
// }
// Enhanced Projects Table Widget with Pagination and Search Highlighting
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
    if (isDeleting) {
      return Container(
        width: double.infinity,
        height: 400, // Adjust height as needed
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
              SizedBox(height: 16),
              Text(
                'Deleting project...',
                style: TextStyle(
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
                Expanded(
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
                Expanded(
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
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: selectedProjectIds.contains(project.id)
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFF5F5F5),
                                border: Border.all(
                                  color: selectedProjectIds.contains(project.id)
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
  void _onProjectSelect(int? projectId) {
    if (projectId == null) return;

    if (selectedProjectIds.contains(projectId)) {
      // If already selected, show delete confirmation
      _showDeleteConfirmationDialog(projectId);
    } else {
      // If not selected, add to selection
      setState(() {
        selectedProjectIds.add(projectId);
      });
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(int projectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Project',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this project? This action cannot be undone.',
            style: TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Remove from selection if user cancels
                setState(() {
                  selectedProjectIds.remove(projectId);
                });
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
                _deleteProject(projectId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete project API call - UPDATED TO USE DELETE METHOD
  Future<void> _deleteProject(int projectId) async {
    try {
      // Set loading state
      setState(() {
        isDeleting = true;
      });

      // Debug logs
      print('Attempting to delete project: $projectId');

      final response = await http.delete(
        // Changed from http.post to http.delete
        Uri.parse('http://127.0.0.1:8000/api/projects/bulk-delete/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'project_ids': [projectId],
        }),
      );

      // Debug logs
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - remove from selection
        setState(() {
          selectedProjectIds.remove(projectId);
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project deleted successfully'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Refresh the projects list by calling the cubit method
        if (mounted) {
          await HomeCubit.get(context).loadHomePage();
          // await context
          //     .read<HomeCubit>()
          //     .loadProjects(); // Call your load projects method
        }
      } else {
        // Error handling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete project: ${response.statusCode}'),
              backgroundColor: const Color(0xFFDC2626),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Remove from selection on error
        setState(() {
          selectedProjectIds.remove(projectId);
        });
      }
    } catch (e) {
      // Network or other errors
      if (mounted) {
        print('Error deleting project: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting project: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Remove from selection on error
      setState(() {
        selectedProjectIds.remove(projectId);
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
}
