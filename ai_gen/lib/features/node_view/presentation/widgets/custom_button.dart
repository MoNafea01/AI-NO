import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    required this.icon,
    this.onTap,
    this.active = true,
    this.borderRadius = 8,
    this.iconSize = 24,
    super.key,
  });

  final VoidCallback? onTap;
  final double borderRadius;
  final double? iconSize;

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? AppColors.bluePrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : Colors.black,
          size: iconSize,
        ),
      ),
    );
  }
}

class AssetIconButton extends StatelessWidget {
  const AssetIconButton({
    required this.iconPath,
    this.onTap,
    this.backgroundColor = AppColors.bluePrimaryColor,
    this.borderRadius = 8,
    this.iconColor = Colors.white,
    this.iconSize = 24,
    super.key,
  });

  final VoidCallback? onTap;

  final double borderRadius;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Image.asset(
          iconPath,
          height: iconSize,
          width: iconSize,
        ),
      ),
    );
  }
}
