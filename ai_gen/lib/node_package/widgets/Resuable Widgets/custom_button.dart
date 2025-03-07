import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onTap,
      required this.width,
      required this.height,
      required this.backgroundColor,
       this.textColor,
      required this.icon,
      required this.borderRadius,
      required this.iconColor,
      required this.iconSize});

  final VoidCallback onTap;
  final double width;
  final double height;
  final double borderRadius;
  final double iconSize;

  final Color iconColor;
  final Color backgroundColor;
  final Color? textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}





class CustomIconButton extends StatelessWidget {
  const CustomIconButton(
      {super.key,
      required this.onTap,
      required this.width,
      required this.height,
      required this.backgroundColor,
       this.textColor,
      required this.iconPath,
      required this.borderRadius,
      required this.iconColor,
      required this.iconSize});

  final VoidCallback onTap;
  final double width;
  final double height;
  final double borderRadius;
  final double iconSize;

  final Color iconColor;
  final Color backgroundColor;
  final Color? textColor;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Image.asset(iconPath),
      ),
    );
  }
}