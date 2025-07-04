import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';

enum ActiveAction { none, sidebar, chat }

class CustomTopAction extends StatelessWidget {
  const CustomTopAction({
    required this.heroTag,
    required this.child,
    this.activeIcon,
    this.inActiveIcon,
    this.iconWidget,
    this.isActive = false,
    this.onTap,
    super.key,
  });

  final Widget child;
  final String heroTag;
  final Widget? iconWidget;
  final IconData? activeIcon;
  final IconData? inActiveIcon;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FloatingActionButton(
          heroTag: heroTag,
          highlightElevation: 0,
          hoverElevation: 0,
          hoverColor: AppColors.grey200,
          mini: true,
          backgroundColor: AppColors.grey100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          foregroundColor: AppColors.black,
          onPressed: onTap,
          child: iconWidget ?? Icon(isActive ? inActiveIcon : activeIcon),
        ),
        // if (isActive)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Offstage(
            offstage: !isActive,
            child: child,
          ),
        ),
      ],
    );
  }
}
