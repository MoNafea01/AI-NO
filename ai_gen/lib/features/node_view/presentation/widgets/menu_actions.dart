import 'package:ai_gen/core/reusable_widgets/custom_menu_item.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:ai_gen/features/screens/HomeScreen/home_screen.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/export_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    GridNodeViewCubit gridNodeViewCubit = context.read<GridNodeViewCubit>();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      offset: const Offset(-30, 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.grey100,
      surfaceTintColor: AppColors.grey100,
      elevation: 8,
      menuPadding: const EdgeInsets.all(12),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildCustomMenuItem(
          "Save Project",
          onTap: gridNodeViewCubit.saveProjectNodes,
        ),
        _buildCustomMenuItem(
          'Export',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: ExportProjectDialog(
                  projectModel: gridNodeViewCubit.projectModel,
                ),
              ),
            );
          },
        ),
        _buildCustomMenuItem(
          'Exit',
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  CustomMenuItem _buildCustomMenuItem(String value, {VoidCallback? onTap}) {
    return CustomMenuItem(
      value,
      onTap: onTap,
      child: Text(value, style: AppTextStyles.titleBlack16Bold),
    );
  }
}
