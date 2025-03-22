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
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is NodeViewSuccess) {
            return const GridNodeView();
          } else if (state is NodeViewFailure) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errMessage),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 36,
                        ),
                      ),
                      onPressed: () =>
                          context.read<GridNodeViewCubit>().buildNodes(),
                      child:
                          const Text('Retry', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Scaffold(body: SizedBox());
          }
        },
      ),
    );
  }
}
