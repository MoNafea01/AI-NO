import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomIconTextButton extends StatelessWidget {
  final String text;
//  final IconData icon;
  final Color backgroundColor;
  final double textSize;
  // final double iconSize;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String assetName; // Example SVG asset path

  const CustomIconTextButton({
    required this.text,
    // required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
    required this.assetName,
    super.key,
    this.textSize = 16,
    //this.iconSize = 24,
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
            SizedBox(
              width: 23,
              height: 24,
              child: SvgPicture.asset(
                fit: BoxFit.cover,
                assetName,

                // ignore: deprecated_member_use
                color: iconColor,
              ),
            ), // Using SVG asset
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
