import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/custom_fab.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/node_view_actions/custom_top_action.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../chatbot/ui/chat_screen.dart';
import 'cubit/grid_node_view_cubit.dart';
import 'widgets/menu_actions.dart';
import 'widgets/node_properties_widget/node_properties_card.dart';
import 'widgets/node_view_actions/node_selector_menu.dart';
import 'widgets/run_button.dart';

class GridNodeView extends StatefulWidget {
  const GridNodeView({super.key});

  @override
  State<GridNodeView> createState() => _GridNodeViewState();
}

class _GridNodeViewState extends State<GridNodeView> {
  static const double _gridWidth = 5000;
  static const double _gridHeight = 5000;
  ActiveAction _activeAction = ActiveAction.none;

  late final VSNodeDataProvider nodeDataProvider;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    nodeDataProvider = context.read<GridNodeViewCubit>().nodeDataProvider;
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
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

    return Scaffold(
      appBar: _buildAppBar(gridNodeViewCubit),
      body: Stack(
        children: [
          _buildInteractiveNodeView(gridNodeViewCubit),
          _buildRunButton(context),
          _buildBottomControls(),
          _buildNodesMenuActionButton(),
          _buildChatActionButton(gridNodeViewCubit),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildNodesMenuActionButton() {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Positioned(
      top: screenHeight / 30,
      left: screenWidth / 50,
      child: CustomTopAction(
        heroTag: 'sidebar_toggle',
        activeIcon: Icons.add,
        inActiveIcon: Icons.close,
        isActive: _activeAction == ActiveAction.sidebar,
        onTap: () {
          setState(() {
            _activeAction == ActiveAction.sidebar
                ? _activeAction = ActiveAction.none
                : _activeAction = ActiveAction.sidebar;
          });
        },
        child: NodeSelectorMenu(vsNodeDataProvider: nodeDataProvider),
      ),
    );
  }

  Widget _buildChatActionButton(GridNodeViewCubit gridNodeViewCubit) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isActive = _activeAction == ActiveAction.chat;
    return Positioned(
      top: screenHeight / 30,
      left: (screenWidth / 50) + 50,
      child: CustomTopAction(
        heroTag: 'Chat with AI',
        iconWidget: isActive
            ? SvgPicture.asset(AssetsPaths.chatBotActiveIcon)
            : SvgPicture.asset(AssetsPaths.chatBotIcon),
        isActive: isActive,
        onTap: () {
          setState(() {
            isActive
                ? _activeAction = ActiveAction.none
                : _activeAction = ActiveAction.chat;
          });
        },
        child: ChatScreen(projectModel: gridNodeViewCubit.projectModel),
      ),
    );
  }

  Widget _buildInteractiveNodeView(GridNodeViewCubit gridNodeViewCubit) {
    return InteractiveVSNodeView(
      width: _gridWidth,
      height: _gridHeight,
      showGrid: gridNodeViewCubit.showGrid,
      nodeDataProvider: nodeDataProvider,
    );
  }

  Widget _buildRunButton(BuildContext context) {
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

  Widget _buildBottomControls() {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Positioned(
      bottom: screenHeight / 50,
      right: screenWidth / 100,
      child: const CustomFAB(),
    );
  }

  Widget _buildVersionInfo() {
    return Positioned(
      bottom: 10,
      left: 10,
      child: Text("V$_appVersion"),
    );
  }

  AppBar _buildAppBar(GridNodeViewCubit gridNodeViewCubit) {
    return AppBar(
      backgroundColor: AppColors.grey100,
      surfaceTintColor: AppColors.grey100,
      foregroundColor: AppColors.black,
      title: Text(
        gridNodeViewCubit.projectModel.name ?? "Project Name",
        style: AppTextStyles.title22,
      ),
      elevation: 1,
      shadowColor: Colors.black,
      leading: null,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: MenuButton(),
        )
      ],
    );
  }
}
