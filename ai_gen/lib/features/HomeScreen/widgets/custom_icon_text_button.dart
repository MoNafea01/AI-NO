import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomIconTextButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double textSize;
  final double iconSize;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String assetName;

  const CustomIconTextButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
    required this.assetName,
    super.key,
    this.textSize = 16,
    this.iconSize = 20, // Default icon size
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
              width: iconSize,
              height: iconSize,
              child:Image.asset(assetName)
              
              
              //  SvgPicture.asset(
              //   assetName,
              //   width: iconSize,
              //   height: iconSize,
              //   fit: BoxFit.contain, // Changed from cover to contain
              //   // ignore: deprecated_member_use
              //   color: iconColor,
              // ),


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
