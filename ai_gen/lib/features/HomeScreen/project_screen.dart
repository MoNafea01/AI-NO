// ignore_for_file: deprecated_member_use

import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/cubit/dashboard_cubit/dash_board_cubit.dart';
import 'package:ai_gen/features/HomeScreen/project_list_item_screen.dart';
import 'package:ai_gen/features/HomeScreen/widgets/create_new_project_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';



import 'data/project_items.dart';

class ProjectsScreen extends StatelessWidget {
  ProjectsScreen({super.key});

  final List<ProjectItem> projects = [
    ProjectItem(
      name: '1st Project name',
      projectDescription: 'description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Content curating app',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: '2nd Project name',
      projectDescription: 'description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Design software',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: '3rd Project name',
      projectDescription: 'description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Data prediction',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: '4th Project name',
      projectDescription: 'description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Productivity app',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: '5th Project name',
      projectDescription: 'description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Web app integrations',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: '6th Project name',
      projectDescription: 'description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Sales CRM',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
    ProjectItem(
      name: '7th Project name',
      projectDescription: 'description',
      modelName: 'Model name',
      modelDescription: 'Model description',
      type: 'Automation and workflow',
      typeDescription: 'Dataset description',
      dateCreated: DateTime(2025, 1, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        // If filteredProjects is empty, use all projects. Otherwise use filtered
        final displayProjects =
            state.filteredProjects.isEmpty && state.searchQuery.isEmpty
                ? projects
                : state.filteredProjects;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                buildHeader(context),

                const SizedBox(height: 24),

                // Search and filter bar
                _buildSearchBar(context, state),

                const SizedBox(height: 24),

                // Table header
                _buildTableHeader(),

                // Project list
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.separated(
                      itemCount: displayProjects.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        return ProjectListItem(project: projects[index]);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Pagination
                _buildPagination(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  

  Widget _buildSearchBar(BuildContext context, DashboardState state) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: TextField(
              onChanged: (query) {
                context.read<DashboardCubit>().searchProjects(query, state.filteredProjects);
              },
              decoration: InputDecoration(
                hintText: 'Find a project',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon:
                    Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.blue.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40), // Checkbox space
          Expanded(
            flex: 2,
            child: Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Model',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Created',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: state.currentPage > 1
              ? () =>
                  context.read<DashboardCubit>().goToPage(state.currentPage - 1)
              : null,
          icon: const Icon(Icons.arrow_back_ios, size: 14),
          label: const Text('Previous'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
        ),
        Row(
          children: [
            for (int i = 1; i <= 3; i++)
              _pageButton(context, i, state.currentPage),
            if (state.currentPage > 4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child:
                    Text('...', style: TextStyle(color: Colors.grey.shade600)),
              ),
            if (state.currentPage >= 4 && state.currentPage <= 7)
              for (int i = 4; i <= 7; i++)
                _pageButton(context, i, state.currentPage),
            if (state.currentPage < 4 || state.currentPage > 7)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child:
                    Text('...', style: TextStyle(color: Colors.grey.shade600)),
              ),
            for (int i = 8; i <= 10; i++)
              _pageButton(context, i, state.currentPage),
          ],
        ),
        TextButton(
          onPressed: state.currentPage < 10
              ? () =>
                  context.read<DashboardCubit>().goToPage(state.currentPage + 1)
              : null,
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
          child: const Row(
            children: [
              Text('Next'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageButton(BuildContext context, int page, int currentPage) {
    final isActive = page == currentPage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => context.read<DashboardCubit>().goToPage(page),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade800,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


Widget buildHeader(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Projects',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'View all your projects',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: SvgPicture.asset(
              AssetsPaths.importIcon,
              width: 16,
              height: 16,
              color: Colors.blue,
            ),
            label: const Text('Import'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue.shade200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          const CreateNewProjectButton(),
        ],
      ),
    ],
  );
}
