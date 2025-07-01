import 'dart:convert';
import 'dart:developer';

import 'package:ai_gen/features/HomeScreen/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:ai_gen/features/HomeScreen/widgets/dialogs/delete_empty_projects_dialog.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../../../../../core/models/project_model.dart';

import 'project_list_item.dart';
import 'projects_table_header.dart';
import 'pagination_controls.dart';

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

  // Method to toggle selection of a project
  void _onProjectSelect(int? projectId) {
    if (projectId == null) return;
    setState(() {
      if (selectedProjectIds.contains(projectId)) {
        selectedProjectIds.remove(projectId);
      } else {
        selectedProjectIds.add(projectId);
      }
    });
  }

  // Method to toggle select/deselect all projects on the current page
  void _toggleSelectAll() {
    setState(() {
      if (selectedProjectIds.isEmpty) {
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
        selectedProjectIds.clear();
      }
    });
  }

  // Method to navigate to the previous page
  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  // Method to navigate to the next page
  void _goToNextPage() {
    HomeSuccess homeState = context.read<HomeCubit>().state as HomeSuccess;
    final totalPages = (homeState.projects.length / itemsPerPage).ceil();

    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  // Method to navigate to a specific page
  void _goToPage(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

  // Method to show delete confirmation dialog for selected projects
  void _showDeleteConfirmationDialog(List<int> projectIds) {
    final HomeSuccess homeState =
        context.read<HomeCubit>().state as HomeSuccess;
    final selectedProjects = homeState.projects
        .where((project) => projectIds.contains(project.id))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          projectIds: projectIds,
          projectNames:
              selectedProjects.map((p) => p.name ?? 'Unnamed Project').toList(),
          onConfirm: _deleteProjects,
        );
      },
    );
  }

  // Method to show delete empty projects confirmation dialog
  void _showDeleteEmptyProjectsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteEmptyProjectsDialog(
          onConfirm: _deleteEmptyProjects,
        );
      },
    );
  }

  // API call to delete selected projects
  Future<void> _deleteProjects(List<int> projectIds) async {
    try {
      // Set loading state
      setState(() {
        isDeleting = true;
      });

      // Debug logs
      log('Attempting to delete projects: $projectIds');

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
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      log('Response headers: ${response.headers}');

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
        log('Error deleting projects: $e');
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

  // API call to delete empty projects
   Future<void> _deleteEmptyProjects() async {
    try {
      // Set loading state
      setState(() {
        isDeletingEmpty = true;
      });

      // Debug logs
      log('Attempting to delete empty projects');

      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/projects/delete-empty-projects/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Debug logs
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
      log('Response headers: ${response.headers}');

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
        log('Error deleting empty projects: $e');
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

    if (isDeleting || isDeletingEmpty) {
      return Container(
        width: double.infinity,
        height: 400,
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
          ProjectsTableHeader(
            selectedProjectIds: selectedProjectIds,
            toggleSelectAll: _toggleSelectAll,
            showDeleteConfirmationDialog: _showDeleteConfirmationDialog,
            showDeleteEmptyProjectsDialog: _showDeleteEmptyProjectsDialog,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currentPageProjects.length,
              itemBuilder: (context, index) {
                final project = currentPageProjects[index];
                return ProjectListItem(
                  project: project,
                  isSelected: selectedProjectIds.contains(project.id),
                  onSelect: _onProjectSelect,
                );
              },
            ),
          ),
          if (totalPages > 1)
            PaginationControls(
              currentPage: currentPage,
              totalPages: totalPages,
              goToPreviousPage: _goToPreviousPage,
              goToNextPage: _goToNextPage,
              goToPage: _goToPage,
            ),
        ],
      ),
    );
  }
}


