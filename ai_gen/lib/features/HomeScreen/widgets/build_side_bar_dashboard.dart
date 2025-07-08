// ignore_for_file: deprecated_member_use

import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/features/HomeScreen/cubit/dashboard_cubit/dash_board_cubit.dart';
import 'package:ai_gen/features/HomeScreen/data/enum_app_screens.dart';
//import 'package:ai_gen/features/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/HomeScreen/widgets/logout_btn.dart';
import 'package:ai_gen/features/HomeScreen/widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

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
                      AppConstants.appName,
                      key: ValueKey('expanded'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
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
                    padding: EdgeInsets.symmetric(
                        horizontal: state.isExpanded ? 16 : 4, vertical: 4),
                    child: state.isExpanded
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedRotation(
                                turns: 0,
                                duration: const Duration(milliseconds: 300),
                                child: Image.asset(
                                  AssetsPaths.collapseIcon,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  TranslationKeys.collapse.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xff383838),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: AnimatedRotation(
                              turns: 0.5,
                              duration: const Duration(milliseconds: 300),
                              child: Image.asset(
                                AssetsPaths.collapseIcon,
                                width: 50,
                                height: 50,
                              ),
                            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 8), // Added padding
          child: const ProfileWidget(),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 2), // Added padding
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
      'label': TranslationKeys.explore.tr,
      'screen': AppScreen.explore
    },
    {
      'icon': AssetsPaths.modelIcon,
      'label': TranslationKeys.models.tr,
      'screen': AppScreen.models
    },
    {
      'icon': AssetsPaths.dataSetsIcon,
      'label': TranslationKeys.datasets.tr,
      'screen': AppScreen.datasets
    },
    {
      'icon': AssetsPaths.learnScreenIcon,
      'label': TranslationKeys.learn.tr,
      'screen': AppScreen.learn
    },
    {
      'icon': AssetsPaths.docsIcon,
      'label': TranslationKeys.docs.tr,
      'screen': AppScreen.docs
    },
    {
      'icon': AssetsPaths.settingIcon,
      'label': TranslationKeys.settings.tr,
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
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 12 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bluePrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment:
              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                iconPath,
                width: isExpanded ? 40 : 50,
                height: isExpanded ? 40 : 50,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
            if (isExpanded) const SizedBox(width: 4),
            if (isExpanded)
              Expanded(
                // Changed from Flexible to Expanded
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
                  child: Text(
                    label,
                    key: ValueKey('$label-expanded'),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? Colors.white : Colors.black,
                        fontFamily: AppConstants.appFontName),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
