import 'package:ai_gen/core/reusable_widgets/failure_screen.dart';
import 'package:ai_gen/core/reusable_widgets/loading_screen.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/main_content.dart';
import 'widgets/side_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomePage(),
      child: const Scaffold(
        backgroundColor: Color(0xfff2f2f2),
        body: Row(
          children: [
            Sidebar(),
            Expanded(child: _Content()),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const LoadingScreen();
        } else if (state is HomeSuccess) {
          return const MainContent();
        }
        return FailureScreen(
          (state as HomeFailure).errMsg,
          onRetry: context.read<HomeCubit>().loadHomePage,
        );
      },
    );
  }
}
