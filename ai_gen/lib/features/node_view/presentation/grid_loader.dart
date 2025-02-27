import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/node_view_cubit.dart';
import 'node_view.dart';

class GridLoader extends StatelessWidget {
  const GridLoader({super.key});

  @override
  Widget build(BuildContext _) {
    return Scaffold(body: _gridBody());
  }

  BlocProvider<BlockLoaderCubit> _gridBody() {
    return BlocProvider(
      create: (context) => BlockLoaderCubit(),
      child: BlocBuilder<BlockLoaderCubit, BlockLoaderState>(
        builder: (context, state) {
          if (state is NodeViewLoading || state is NodeViewInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NodeViewSuccess) {
            return NodeView(nodeBuilder: state.nodeBuilder);
          } else if (state is NodeViewFailure) {
            return Center(child: Text(state.errMessage));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
