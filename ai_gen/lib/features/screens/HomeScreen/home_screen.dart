import 'package:ai_gen/core/reusable_widgets/failure_screen.dart';
import 'package:ai_gen/core/reusable_widgets/loading_screen.dart';
import 'package:ai_gen/features/HomeScreen/project_screen.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/header_section.dart';
import 'widgets/project_table.dart';
import 'widgets/search_and_action.dart';
import 'widgets/side_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomePage(),
      child: Scaffold(
        backgroundColor: const Color(0xfff2f2f2),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // i want here to get only [table details , bottom btns ]

              // Sidebar(),
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
                      const SearchAndActionsRow(), //old search and actions row
                      // buildSearchBar(context),
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
        }
        return FailureScreen(
          (state as HomeFailure).errMsg,
          onRetry: context.read<HomeCubit>().loadHomePage,
        );
      },
    );
  }
}
