import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../menu_actions.dart';

class NodeViewExpandableFab extends StatelessWidget {
  const NodeViewExpandableFab({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      childrenOffset: const Offset(-10, -60),
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.keyboard_arrow_up),
        fabSize: ExpandableFabSize.small,
        foregroundColor: Colors.black,
        backgroundColor: AppColors.grey100,
        shape: const CircleBorder(),
        heroTag: "Open menu",
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        child: const Icon(Icons.keyboard_arrow_down),
        fabSize: ExpandableFabSize.small,
        foregroundColor: Colors.black,
        backgroundColor: AppColors.grey100,
        shape: const CircleBorder(),
        heroTag: "Close menu",
      ),
      children: const [ExpandableMenuActions()],
    );
  }
}
