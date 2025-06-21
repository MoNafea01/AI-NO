import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';

abstract class AppTextStyles {
  static const TextStyle title24 = TextStyle(
    fontSize: 24,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.blackText2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    color: AppColors.blackText2,
  );

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

  //node title
  static const TextStyle nodeTitleTextStyle = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle black16w400 = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.blackText,
  );

  static const TextStyle black14Bold = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.blackText,
  );
  static const TextStyle black14w400 = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.blackText,
  );
  static const TextStyle black14Normal = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.blackText,
  );

  //node output&input
  static const TextStyle nodeInterfaceTextStyle = TextStyle(
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
}
