import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/grid_node_view_cubit.dart';
import 'grid_node_view.dart';

class NodeView extends StatelessWidget {
  const NodeView({super.key});

  @override
  Widget build(BuildContext _) {
    return BlocProvider(
      create: (context) => GridNodeViewCubit()..buildNodes(),
      child: BlocBuilder<GridNodeViewCubit, GridNodeViewState>(
        builder: (context, state) {
          if (state is GridNodeViewLoading || state is GridNodeViewInitial) {
            return const LoadingScreen();
          } else if (state is NodeViewFailure) {
            return _FailureScreen(state.errMessage);
          } else if (state is NodeViewSuccess) {
            return const GridNodeView();
          } else {
            return const Scaffold(body: SizedBox());
          }
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _FailureScreen extends StatelessWidget {
  const _FailureScreen(this.errorMessage);

  final String errorMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 36,
                ),
              ),
              onPressed: () => context.read<GridNodeViewCubit>().buildNodes(),
              child: const Text('Retry', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
