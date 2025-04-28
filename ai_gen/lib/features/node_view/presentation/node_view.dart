import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/reusable_widgets/failure_screen.dart';
import 'package:ai_gen/core/reusable_widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/grid_node_view_cubit.dart';
import 'grid_node_view.dart';

class NodeView extends StatelessWidget {
  const NodeView({required this.projectModel, super.key});

  final ProjectModel projectModel;

  @override
  Widget build(BuildContext _) {
    return BlocProvider(
      create: (context) =>
          GridNodeViewCubit(projectModel: projectModel)..loadNodeView(),
      child: BlocBuilder<GridNodeViewCubit, GridNodeViewState>(
        builder: (context, state) {
          if (state is GridNodeViewLoading || state is GridNodeViewInitial) {
            return const LoadingScreen();
          } else if (state is NodeViewFailure) {
            return FailureScreen(
              state.errMessage,
              onRetry: context.read<GridNodeViewCubit>().loadNodeView,
            );
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
