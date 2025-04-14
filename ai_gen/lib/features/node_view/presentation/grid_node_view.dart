import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/menu_actions.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/grid_node_view_cubit.dart';
import 'widgets/node_properties_widget/node_properties_card.dart';
import 'widgets/node_selector_sidebar/node_selector_sidebar.dart';
import 'widgets/run_button.dart';

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
            child: const RunButton(),
          ),
          Positioned(
            top: 112,
            right: screenWidth / 100,
            child: const NodePropertiesCard(),
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
}
