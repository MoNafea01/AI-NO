import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vs_node_view/data/vs_node_data_provider.dart';
import 'package:vs_node_view/widgets/interactive_vs_node_view.dart';

import 'cubits/grid_node_view_cubit.dart';

class GridNodeView extends StatefulWidget {
  const GridNodeView({super.key});

  @override
  State<GridNodeView> createState() => _GridNodeViewState();
}

class _GridNodeViewState extends State<GridNodeView> {
  late final VSNodeDataProvider nodeDataProvider;

  @override
  void initState() {
    super.initState();
    nodeDataProvider = context.read<GridNodeViewCubit>().nodeDataProvider;
  }

  @override
  void dispose() {
    nodeDataProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: _appBar(),
      body: Stack(
        children: [
          InteractiveVSNodeView(
            width: 5000,
            height: 5000,
            nodeDataProvider: nodeDataProvider,
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _evaluateButton(),
                if (context.watch<GridNodeViewCubit>().results != null)
                  ...context.watch<GridNodeViewCubit>().results!.map(
                    (scopeOutput) {
                      scopeOutput = scopeOutput.replaceAll(",", ",\n");
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(scopeOutput),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.grey50,
      surfaceTintColor: AppColors.grey50,
      title: const Text("Project 1"),
      elevation: 1,
      shadowColor: Colors.black,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 32),
          child: Icon(Icons.menu),
        )
      ],
    );
  }

  ElevatedButton _evaluateButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF4F),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: context.read<GridNodeViewCubit>().runNodes,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.play_arrow, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Run",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
