import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/reusable_widgets/failure_screen.dart';
import 'package:ai_gen/core/utils/reusable_widgets/loading_screen.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/HomeScreen/cubit/home_cubit/home_cubit.dart';
import 'package:ai_gen/features/HomeScreen/widgets/build_dashboard_header.dart';
import 'package:ai_gen/features/HomeScreen/widgets/projects_table/projects_table.dart';
import 'package:ai_gen/features/HomeScreen/widgets/search_and_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.projectModel});

  final ProjectModel? projectModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomePage(),
      child: Scaffold(
        backgroundColor: const Color(0xfff2f2f2),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 800;
            final horizontalPadding = isSmallScreen ? 16.0 : 65.0;
            final verticalPadding = isSmallScreen ? 10.0 : 20.0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0.5, vertical: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: constraints.maxHeight - 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BuildDashboardHeader(projectModel: projectModel),

                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Search and Actions Row
                              const SearchAndActionsRow(),

                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Content Section
                              Expanded(
                                child: _Content(isSmallScreen: isSmallScreen),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final bool isSmallScreen;

  const _Content({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const LoadingScreen();
        } else if (state is HomeSuccess) {
          return const ProjectsTable();
        } else if (state is HomeSearchEmpty) {
          return _buildEmptySearchState(context, state);
        }
        return FailureScreen(
          (state as HomeFailure).errMsg,
          onRetry: context.read<HomeCubit>().loadHomePage,
        );
      },
    );
  }

  Widget _buildEmptySearchState(BuildContext context, HomeSearchEmpty state) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? 300 : 400,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isSmallScreen ? 48 : 64,
              color: AppColors.bluePrimaryColor,
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${TranslationKeys.noResultsFoundFor.tr}${state.query}"',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  TranslationKeys.trySearchingWithDifferentKeywords.tr,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? 120 : 150,
                maxWidth: isSmallScreen ? 200 : 250,
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<HomeCubit>().searchProjects('');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    TranslationKeys.showAllProjects.tr,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
