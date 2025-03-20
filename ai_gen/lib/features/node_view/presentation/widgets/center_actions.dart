import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/asset_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/grid_node_view_cubit.dart';
import 'custom_button.dart';

class CenterActions extends StatelessWidget {
  const CenterActions({super.key});

  @override
  Widget build(BuildContext context) {
    final GridNodeViewCubit gridNodeViewCubit =
        context.read<GridNodeViewCubit>();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          _toggleGridButton(gridNodeViewCubit),
          const AssetIconButton(iconPath: AssetsPaths.arrowSelector),
          const CustomIconButton(
            icon: Icons.keyboard_arrow_down_sharp,
            active: false,
          ),
        ],
      ),
    );
  }

  CustomIconButton _toggleGridButton(GridNodeViewCubit gridNodeViewCubit) {
    return CustomIconButton(
      icon: gridNodeViewCubit.showGrid
          ? Icons.grid_4x4_sharp
          : Icons.grid_off_rounded,
      onTap: gridNodeViewCubit.toggleGrid,
      active: gridNodeViewCubit.showGrid,
    );
  }
}
