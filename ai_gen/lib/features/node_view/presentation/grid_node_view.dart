import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/menu_actions.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/grid_node_view_cubit.dart';
import 'widgets/node_properties_widget/node_properties_card.dart';
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
            top: 32,
            right: screenWidth / 100,
            child: _run(gridNodeViewCubit),
          ),
          Positioned(
            top: 112,
            right: screenWidth / 100,
            child: NodePropertiesCard(
              node: NodeModel(
                id: 1,
                name: 'Logistic Regression',
                displayName: 'Logistic Regression',
                description: 'Logistic Regression',
                category: 'Classification',
                type: 'Classifier',
                task: 'Classification',
                outputDots: [
                  "model",
                  "model",
                  "model",
                  "model",
                ],
                inputDots: [
                  "model",
                  "model",
                  "model",
                  "model",
                ],
                params: [
                  ParameterModel(
                      name: 'penalty', type: "str", defaultValue: 'l2'),
                  ParameterModel(name: 'C', type: "float", defaultValue: 1.0),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight / 50,
            right: screenWidth / 100,
            child: const ExpandableMenuActions(),
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

  Column _run(GridNodeViewCubit gridNodeViewCubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _runButton(),
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
      backgroundColor: AppColors.grey50,
      surfaceTintColor: AppColors.grey50,
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<GridNodeViewCubit>().clearNodes(),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 32),
          child: Icon(Icons.close),
        ),
      ],
    );
  }

  ElevatedButton _runButton() {
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
