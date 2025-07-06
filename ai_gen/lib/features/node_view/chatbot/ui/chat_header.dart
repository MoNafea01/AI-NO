import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(AssetsPaths.projectLogoIcon),
              const SizedBox(width: 8),
              const Text('AINO', style: AppTextStyles.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}
