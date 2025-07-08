

import 'dart:developer';

import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/HomeScreen/cubit/dashboard_cubit/dash_board_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/home_cubit/home_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_gen/features/HomeScreen/screens/home_screen.dart';
import 'package:ai_gen/features/HomeScreen/screens/profile_screen.dart';
import 'package:ai_gen/features/HomeScreen/widgets/build_side_bar_dashboard.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/dashboard_screens/learnScreen/learn_screen.dart';
import 'package:ai_gen/features/dashboard_screens/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocBuilder, BlocProvider, MultiBlocProvider, ReadContext;

import '../../dashboard_screens/datasetScreen/screens/dataset_screen.dart';
import '../../dashboard_screens/docsScreen/docs_screen.dart';
import '../../dashboard_screens/modelScreen/screens/model_screen.dart';
import '../data/enum_app_screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.projectModel});

  final ProjectModel? projectModel;

  @override
  Widget build(BuildContext context) {
    log("DashboardScreen");
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardCubit(),
        ),
        BlocProvider(
          create: (context) => HomeCubit()..loadHomePage(),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(
            context.read<AuthProvider>(),
          )..loadProfile(),
        ),
      ],
      child: _DashboardView(projectModel: projectModel),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({this.projectModel});

  final ProjectModel? projectModel;

  // Helper method to get the widget based on the selected screen
  Widget _getScreenWidget(AppScreen screen) {
    switch (screen) {
      case AppScreen.explore:
        return HomeScreen(projectModel: projectModel);
      case AppScreen.models:
        return const ModelsScreen();
      case AppScreen.datasets:
        return const DatasetsScreen();
      case AppScreen.learn:
        return const PlaylistScreen();
      case AppScreen.docs:
        return const DocsScreen();
      case AppScreen.settings:
        return const SettingsScreen();
      case AppScreen.profile:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
         
          final isVerySmallScreen = constraints.maxWidth < 600;
          final isSmallScreen = constraints.maxWidth < 900;

          return BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (isVerySmallScreen) {
              
                return _buildMobileLayout(context, state);
              } else {
             
                return _buildDesktopLayout(context, state, isSmallScreen);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, DashboardState state, bool isSmallScreen) {
    return Row(
      children: [
       
        buildSidebar(context, state),

        // Main Content
        Expanded(
          child: Container(
            
            constraints: const BoxConstraints(
              minWidth: 200,
            ),
            child: ClipRect(
              child: _getScreenWidget(state.selectedScreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, DashboardState state) {
    return Column(
      children: [
     
        Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Menu Button
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                
                  Scaffold.of(context).openDrawer();
                },
              ),

              // Title
              Expanded(
                child: Text(
                  _getScreenTitle(state.selectedScreen),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Content
        Expanded(
          child: _getScreenWidget(state.selectedScreen),
        ),
      ],
    );
  }

  String _getScreenTitle(AppScreen screen) {
    switch (screen) {
      case AppScreen.explore:
        return 'Projects';
      case AppScreen.models:
        return 'Models';
      case AppScreen.datasets:
        return 'Datasets';
      case AppScreen.learn:
        return 'Learn';
      case AppScreen.docs:
        return 'Docs';
      case AppScreen.settings:
        return 'Settings';
      case AppScreen.profile:
        return 'Profile';
    }
  }
}


Widget buildResponsiveSidebar(BuildContext context, DashboardState state) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final parentConstraints = MediaQuery.of(context).size;
      final isSmallScreen = parentConstraints.width < 800;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSmallScreen
            ? 60
            : 250, 
        child: buildSidebar(context, state),
      );
    },
  );
}
