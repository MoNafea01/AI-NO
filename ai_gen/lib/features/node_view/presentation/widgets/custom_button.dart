import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    required this.icon,
    this.onTap,
    this.backgroundColor = AppColors.bluePrimaryColor,
    this.borderRadius = 8,
    this.iconColor = Colors.white,
    this.iconSize = 24,
    super.key,
  });

  final VoidCallback? onTap;
  final double borderRadius;
  final double? iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
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
        padding: EdgeInsets.all(8),
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
