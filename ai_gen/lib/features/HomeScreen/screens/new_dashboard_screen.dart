// ignore_for_file: deprecated_member_use

import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/HomeScreen/cubit/dashboard_cubit/dash_board_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/home_cubit/home_cubit.dart';
import 'package:ai_gen/features/HomeScreen/cubit/user_profile_cubit/user_profile_cubit.dart';
import 'package:ai_gen/features/HomeScreen/screens/home_screen.dart';
import 'package:ai_gen/features/HomeScreen/screens/profile_screen.dart';
import 'package:ai_gen/features/HomeScreen/widgets/build_side_bar_dashboard.dart';
import 'package:ai_gen/features/auth/presentation/widgets/auth_provider.dart';
import 'package:ai_gen/features/learnScreen/learn_screen.dart';


import 'package:ai_gen/features/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, BlocProvider, MultiBlocProvider, ReadContext;


import '../../datasetScreen/screens/dataset_screen.dart';
import '../../docsScreen/docs_screen.dart';

import '../../modelScreen/screens/model_screen.dart';
import '../data/enum_app_screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.projectModel});

  final ProjectModel? projectModel;

  @override
  Widget build(BuildContext context) {
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
      //return ProjectsScreen();
      //ProjectsTable
      // case AppScreen.architectures:
      //   return const ArchitecturesScreen();
      case AppScreen.models:
        return const ModelsScreen();
      case AppScreen.datasets:
        return const DatasetsScreen();
      case AppScreen.learn:
      //  return const LearnScreen(); LearningScreen
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
      
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return Row(
            children: [
              // Left Sidebar
              buildSidebar(context, state),

              // Main Content
              Expanded(
                child: _getScreenWidget(state
                    .selectedScreen), // Dynamically display the selected screen
              ),
            ],
          );
        },
      ),
    );
  }
}
