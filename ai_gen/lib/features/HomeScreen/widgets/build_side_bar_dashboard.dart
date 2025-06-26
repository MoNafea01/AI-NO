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
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
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
            mainAxisAlignment: state.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AssetsPaths.projectLogoIcon,
                width: 24,
                height: 24,
              ),
              if (state.isExpanded) const SizedBox(width: 8),
              if (state.isExpanded)
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: child,
                        ),
                      );
                    },
                    child: const Text(
                      'Model Craft',
                      key: ValueKey('expanded'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
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
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: state.isExpanded
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.center,
                      children: [
                        AnimatedRotation(
                          turns: state.isExpanded ? 0 : 0.5,
                          duration: const Duration(milliseconds: 300),
                          child: SvgPicture.asset(
                            AssetsPaths.expandedIcon,
                            width: 20,
                            height: 20,
                            color: const Color(0xff666666),
                          ),
                        ),
                        if (state.isExpanded) const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                child: child,
                              ),
                            );
                          },
                          child: state.isExpanded
                              ? const Text(
                                  "Collapse",
                                  key: ValueKey('collapse-text'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xff383838),
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('no-text')),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...buildAnimatedSidebarItems(context, state),
              ],
            ),
          ),
        ),
        const Divider(
          color: Colors.transparent,
          thickness: 1,
          height: 1,
        ),
        Container(
          width: double.infinity,
          alignment: state.isExpanded ? Alignment.centerLeft : Alignment.center,
          child: const ProfileWidget(),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          alignment: state.isExpanded ? Alignment.centerLeft : Alignment.center,
          child: logoutButton(context, state.isExpanded),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

List<Widget> buildAnimatedSidebarItems(
    BuildContext context, DashboardState state) {
  final items = [
    {
      'icon': AssetsPaths.exploreIcon,
      'label': 'Explore',
      'screen': AppScreen.explore
    },
    {
      'icon': AssetsPaths.architectureIcon,
      'label': 'Architectures',
      'screen': AppScreen.architectures
    },
    {
      'icon': AssetsPaths.modelIcon,
      'label': 'Models',
      'screen': AppScreen.models
    },
    {
      'icon': AssetsPaths.dataSetsIcon,
      'label': 'Datasets',
      'screen': AppScreen.datasets
    },
    {
      'icon': AssetsPaths.learnIcon,
      'label': 'Learn',
      'screen': AppScreen.learn
    },
    {'icon': AssetsPaths.docsIcon, 'label': 'Docs', 'screen': AppScreen.docs},
    {
      'icon': AssetsPaths.settingIcon,
      'label': 'Settings',
      'screen': AppScreen.settings
    },
  ];

  return items
      .map((item) => animatedSidebarItem(
            context,
            item['icon'] as String,
            item['label'] as String,
            item['screen'] as AppScreen,
            state.isExpanded,
          ))
      .toList();
}

Widget animatedSidebarItem(
  BuildContext context,
  String iconPath,
  String label,
  AppScreen screenType,
  bool isExpanded,
) {
  final bool isActive =
      context.watch<DashboardCubit>().state.selectedScreen == screenType;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    child: InkWell(
      onTap: () {
        context.read<DashboardCubit>().selectNavigationItem(screenType);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment:
              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                iconPath,
                width: 20,
                height: 20,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
            if (isExpanded) const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    child: child,
                  ),
                );
              },
              child: isExpanded
                  ? Text(
                      label,
                      key: ValueKey('$label-expanded'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            isActive ? FontWeight.w500 : FontWeight.normal,
                        color: isActive ? Colors.white : Colors.black,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('collapsed-text')),
            ),
          ],
        ),
      ),
    ),
  );
}
