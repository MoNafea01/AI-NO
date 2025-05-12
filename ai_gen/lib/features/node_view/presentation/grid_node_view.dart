import 'package:ai_gen/core/reusable_widgets/custom_button.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/custom_fab.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/grid_node_view_cubit.dart';
import 'widgets/menu_actions.dart';
import 'widgets/node_properties_widget/node_properties_card.dart';
import 'widgets/node_selector_sidebar/node_selector_sidebar.dart';
import 'widgets/run_button.dart';

class GridNodeView extends StatefulWidget {
  const GridNodeView({super.key});

  @override
  State<GridNodeView> createState() => _GridNodeViewState();
}

class _GridNodeViewState extends State<GridNodeView> {
  static const double _gridWidth = 5000;
  static const double _gridHeight = 5000;
  static const Duration _sidebarAnimationDuration = Duration(milliseconds: 500);
  static const double _sidebarWidth = 500;

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
    final GridNodeViewCubit gridNodeViewCubit =
        context.watch<GridNodeViewCubit>();
    final bool isSidebarVisible = gridNodeViewCubit.isSidebarVisible;

    return Scaffold(
      appBar: _buildAppBar(gridNodeViewCubit, isSidebarVisible),
      body: Stack(
        children: [
          _buildNodeView(gridNodeViewCubit),
          _buildTopControls(context),
          _buildBottomControls(context),
          _buildSidebar(isSidebarVisible),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildNodeView(GridNodeViewCubit gridNodeViewCubit) {
    return InteractiveVSNodeView(
      width: _gridWidth,
      height: _gridHeight,
      showGrid: gridNodeViewCubit.showGrid,
      nodeDataProvider: nodeDataProvider,
    );
  }

  Widget _buildTopControls(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Positioned(
      top: 32,
      right: screenWidth / 100,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RunButton(),
          SizedBox(height: 20),
          NodePropertiesCard(),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Positioned(
      bottom: screenHeight / 50,
      right: screenWidth / 100,
      child: const CustomFAB(),
    );
  }

  Widget _buildSidebar(bool isSidebarVisible) {
    return AnimatedPositioned(
      duration: _sidebarAnimationDuration,
      top: 0,
      left: isSidebarVisible ? 0 : -_sidebarWidth,
      child: NodeSelectorSidebar(vsNodeDataProvider: nodeDataProvider),
    );
  }

  Widget _buildVersionInfo() {
    return const Positioned(
      bottom: 10,
      left: 10,
      child: Text("V0.8.5"),
    );
  }

  AppBar _buildAppBar(
      GridNodeViewCubit gridNodeViewCubit, bool isSidebarVisible) {
    return AppBar(
      backgroundColor: AppColors.grey100,
      surfaceTintColor: AppColors.grey100,
      title: Text(gridNodeViewCubit.projectModel.name ?? "Project Name"),
      elevation: 1,
      shadowColor: Colors.black,
      leading: CustomButton(
        radius: 8,
        child: Icon(isSidebarVisible ? Icons.arrow_back : Icons.menu),
        onTap: () => gridNodeViewCubit.toggleSidebar(),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: MenuButton(),
        )
      ],
    );
  }
}
