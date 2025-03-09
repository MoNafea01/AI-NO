import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/asset_paths.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';

class CenterActions extends StatelessWidget {
  const CenterActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          CustomIconButton(
            icon: Icons.add,
            iconColor: Colors.black,
            backgroundColor: Colors.transparent,
          ),
          CustomIconButton(
            icon: Icons.grid_4x4_sharp,
            // : Icons.grid_off_rounded,
          ),
          AssetIconButton(iconPath: AssetsPaths.arrowSelector),
          CustomIconButton(
            icon: Icons.keyboard_arrow_down_sharp,
            iconColor: Colors.black,
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
