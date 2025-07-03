import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';


class CustomLanguageContainer {
  static Widget getCustomLanguageContainer({
    required Color backgroundColor,
    required String text, Color textColor = AppColors.white,
    BorderRadius? borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
