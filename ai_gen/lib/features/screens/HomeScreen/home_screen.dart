import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/reusable_widgets/failure_screen.dart';
import 'package:ai_gen/core/utils/reusable_widgets/loading_screen.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/HomeScreen/widgets/build_dashboard_header.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/project_table.dart';
import 'widgets/search_and_action.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.projectModel});

  final ProjectModel? projectModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomePage(),
      child: Scaffold(
        backgroundColor: const Color(0xfff2f2f2),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 65, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      // HeaderSection(), // old header section
                      buildHeader(context),
                      SearchAndActionsRow(
                        projectModel: projectModel,
                      ), //old search and actions row
                      
                      const Expanded(child: _Content()),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const LoadingScreen();
        } else if (state is HomeSuccess) {
          return const ProjectsTable();
        } else if (state is HomeSearchEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.bluePrimaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No projects found for "${state.query}"',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching with different keywords',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Clear search and show all projects
                    context.read<HomeCubit>().searchProjects('');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluePrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Show All Projects'),
                ),
              ],
            ),
          );
        }
        return FailureScreen(
          (state as HomeFailure).errMsg,
          onRetry: context.read<HomeCubit>().loadHomePage,
        );
      },
    );
  }
}
