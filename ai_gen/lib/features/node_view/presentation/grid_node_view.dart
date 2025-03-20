import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/center_actions.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/grid_node_view_cubit.dart';
import 'widgets/node_selector_sidebar/node_selector_sidebar.dart';

class GridNodeView extends StatefulWidget {
  const GridNodeView({super.key});

  @override
  State<GridNodeView> createState() => _GridNodeViewState();
}

class _GridNodeViewState extends State<GridNodeView> {
  late final VSNodeDataProvider nodeDataProvider;
  bool isSidebarVisible = true;

  @override
  void initState() {
    nodeDataProvider = context.read<GridNodeViewCubit>().nodeDataProvider;
    super.initState();
  }

  @override
  void dispose() {
    nodeDataProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final GridNodeViewCubit gridNodeViewCubit =
        context.watch<GridNodeViewCubit>();
    return Scaffold(
      appBar: _appBar(),
      body: Stack(
        children: [
          InteractiveVSNodeView(
            width: 5000,
            height: 5000,
            showGrid: gridNodeViewCubit.showGrid,
            nodeDataProvider: nodeDataProvider,
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _outputCards(gridNodeViewCubit),
          ),
          Positioned(
            bottom: screenHeight / 45,
            right: screenWidth / 100,
            child: const CenterActions(),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: 0,
            left: isSidebarVisible ? 0 : -500,
            child: NodeSelectorSidebar(vsNodeDataProvider: nodeDataProvider),
          ),
        ],
      ),
    );
  }

  Column _outputCards(GridNodeViewCubit gridNodeViewCubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _evaluateButton(),
        if (gridNodeViewCubit.results != null)
          ...gridNodeViewCubit.results!.map(
            (scopeOutput) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(scopeOutput),
                ),
              );
            },
          ),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.nodeViewBackgroundColor,
      surfaceTintColor: AppColors.nodeViewBackgroundColor,
      title: const Text("Project 1"),
      elevation: 1,
      shadowColor: Colors.black,
      leading: IconButton(
        icon: Icon(isSidebarVisible ? Icons.arrow_back : Icons.menu),
        onPressed: () {
          setState(() {
            isSidebarVisible = !isSidebarVisible;
          });
        },
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 32),
          child: Icon(Icons.menu),
        ),
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
