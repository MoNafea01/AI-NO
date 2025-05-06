import 'package:ai_gen/core/reusable_widgets/custom_button.dart';
import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/menu_actions.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

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
      appBar: _appBar(gridNodeViewCubit),
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
          const Positioned(
            bottom: 10,
            left: 10,
            child: Text("V0.8.0+2"),
          ),
        ],
      ),
    );
  }

  AppBar _appBar(GridNodeViewCubit gridNodeViewCubit) {
    return AppBar(
      backgroundColor: AppColors.grey50,
      surfaceTintColor: AppColors.grey50,
      title: Text(gridNodeViewCubit.projectModel.name ?? "Project Name"),
      elevation: 1,
      shadowColor: Colors.black,
      leading: CustomButton(
        radius: 8,
        child: Icon(isSidebarVisible ? Icons.arrow_back : Icons.menu),
        onTap: () {
          setState(() => isSidebarVisible = !isSidebarVisible);
        },
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            CustomButton(
              onTap: () => context.read<GridNodeViewCubit>().clearNodes(),
              child: SvgPicture.asset(AssetsPaths.refreshIcon, height: 18),
            ),
            CustomButton(
              onTap: () =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              )),
              child: const Icon(Icons.home),
            ),
            const SizedBox(),
          ],
        )
      ],
    );
  }
}
