import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator(
      color: AppColors.bluePrimaryColor,
    )));
  }
}
