import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle titleBlack16Bold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle textSecondary = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
  static const TextStyle black16w400 = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.blackText,
  );

  static const TextStyle black14w400 = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.blackText,
  );
}
