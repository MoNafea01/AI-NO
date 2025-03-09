import 'package:flutter/material.dart';

class CustomIconTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final double textSize;
  final double iconSize;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  const CustomIconTextButton({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    this.textSize = 16,
    this.iconSize = 24,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: textSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
