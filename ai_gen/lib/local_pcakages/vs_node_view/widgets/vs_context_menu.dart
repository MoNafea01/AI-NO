import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';

import '../data/vs_node_data_provider.dart';

class VSContextMenu extends StatefulWidget {
  ///Base context menu
  ///
  ///Used in [VSNodeView] to create new nodes
  const VSContextMenu({
    required this.nodeBuilders,
    this.vsNodeDataProvider,
    super.key,
  });
  final VSNodeDataProvider? vsNodeDataProvider;

  ///A map of all nodeBuilders. In this format:
  ///
  ///{
  /// Subgroup:{
  ///   nodeName: NodeBuilder
  /// },
  /// nodeName: NodeBuilder
  ///}
  final Map<String, dynamic> nodeBuilders;

  @override
  State<VSContextMenu> createState() => _VSContextMenuState();
}

class _VSContextMenuState extends State<VSContextMenu> {
  late Map<String, dynamic> nodeBuilders;

  @override
  void initState() {
    super.initState();
    nodeBuilders =
        widget.vsNodeDataProvider?.nodeBuildersMap ?? widget.nodeBuilders;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    final entries = nodeBuilders.entries;

    for (final entry in entries) {
      if (entry.value is Map) {
        widgets.add(
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.blackText,
              iconColor: AppColors.blackText,
            ),
            onPressed: () => setState(() {
              nodeBuilders = entry.value;
            }),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                Text(entry.key, style: AppTextStyles.black14Normal),
              ],
            ),
          ),
        );
      } else {
        widgets.add(TextButton(
          onPressed: () {
            final dataProvider =
                widget.vsNodeDataProvider ?? VSNodeDataProvider.of(context);
            dataProvider.createNodeFromContext(entry.value);
            dataProvider.closeContextMenu();
          },
          child: Text(entry.key, style: AppTextStyles.black14Normal),
        ));
      }
      if (entry.key != entries.last.key) {
        widgets.add(const Divider());
      }
    }

    return GestureDetector(
      child: Card(
        color: AppColors.grey100,
        surfaceTintColor: AppColors.grey100,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ),
        ),
      ),
    );
  }
}
