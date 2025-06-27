import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/cubit/dashboard_cubit/dash_board_cubit.dart';
import 'package:ai_gen/features/HomeScreen/data/enum_app_screens.dart';
//import 'package:ai_gen/features/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/HomeScreen/widgets/logout_btn.dart';
import 'package:ai_gen/features/HomeScreen/widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

Widget buildSidebar(BuildContext context, DashboardState state) {
  return Container(
    width: state.isExpanded ? 230 : 110,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        right: BorderSide(
          color: Colors.black.withOpacity(0.21),
          width: 2,
        ),
      ),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SvgPicture.asset(
                AssetsPaths.projectLogoIcon,
                width: 24,
                height: 24,
              ),
              if (state.isExpanded) const SizedBox(width: 8),
              if (state.isExpanded)
                const Text(
                  'A I N O',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<DashboardCubit>().toggleSidebar();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AssetsPaths.expandedIcon,
                          width: 20,
                          height: 20,
                          color: const Color(0xff666666)),
                      const SizedBox(width: 8),
                      if (state.isExpanded)
                        const Text("Collapse",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xff383838),
                            )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                sidebarItem(
                  context,
                  AssetsPaths.exploreIcon,
                  'Explore',
                  AppScreen.explore, // Use enum
                  state.isExpanded,
                ),
                sidebarItem(
                  context,
                  AssetsPaths.architectureIcon,
                  'Architectures',
                  AppScreen.architectures, // Use enum
                  state.isExpanded,
                ),
                sidebarItem(
                  context,
                  AssetsPaths.modelIcon,
                  'Models',
                  AppScreen.models, // Use enum
                  state.isExpanded,
                ),
                sidebarItem(
                  context,
                  AssetsPaths.dataSetsIcon,
                  'Datasets',
                  AppScreen.datasets, // Use enum
                  state.isExpanded,
                ),
                sidebarItem(
                  context,
                  AssetsPaths.learnIcon,
                  'Learn',
                  AppScreen.learn, // Use enum
                  state.isExpanded,
                ),
                sidebarItem(
                  context,
                  AssetsPaths.docsIcon,
                  'Docs',
                  AppScreen.docs, // Use enum for Docs
                  state.isExpanded,
                ),
                sidebarItem(
                  context,
                  AssetsPaths.settingIcon,
                  'Settings',
                  AppScreen.settings, // Use enum
                  state.isExpanded,
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        const ProfileWidget(),
        const SizedBox(height: 8),
        logoutButton(context, state.isExpanded),
        const SizedBox(height: 16),
      ],
    ),
  );
}

Widget sidebarItem(
  BuildContext context,
  String iconPath,
  String label,
  AppScreen screenType, // Now takes AppScreen
  bool isExpanded,
) {
  final bool isActive = context.watch<DashboardCubit>().state.selectedScreen ==
      screenType; // Compare with AppScreen
  return InkWell(
    onTap: () {
      context
          .read<DashboardCubit>()
          .selectNavigationItem(screenType); // Select the screen type
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.bluePrimaryColor : Colors.transparent,
        borderRadius: isActive
            ? const BorderRadius.all(
                Radius.circular(4),
              )
            : null,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            color: isActive ? Colors.white : Colors.grey.shade700,
          ),
          if (isExpanded) const SizedBox(width: 12),
          if (isExpanded)
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                color: isActive
                    ? Colors.white
                    : Colors
                        .black, //isActive ? Colors.white : Colors.grey.shade800
              ),
            ),
        ],
      ),
    ),
  );
}
