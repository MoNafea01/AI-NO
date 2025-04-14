import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/grid_node_view_cubit.dart';
import 'custom_button.dart';

class ExpandableMenuActions extends StatefulWidget {
  const ExpandableMenuActions({super.key});

  @override
  _ExpandableMenuActionsState createState() => _ExpandableMenuActionsState();
}

class _ExpandableMenuActionsState extends State<ExpandableMenuActions> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final GridNodeViewCubit gridNodeViewCubit =
        context.read<GridNodeViewCubit>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isExpanded ? 8 : 0),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isExpanded) ...[
            _toggleGridButton(gridNodeViewCubit),
          ],
          IconButton(
            style: IconButton.styleFrom(padding: EdgeInsets.zero),
            icon: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onPressed: () {
              setState(() => isExpanded = !isExpanded);
            },
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
      iconSize: 16,
      onTap: () {
        setState(() => gridNodeViewCubit.toggleGrid());
      },
      active: gridNodeViewCubit.showGrid,
    );
  }
}
