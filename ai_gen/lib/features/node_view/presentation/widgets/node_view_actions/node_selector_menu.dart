import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/local_pcakages/vs_node_view/vs_node_view.dart';
import 'package:flutter/material.dart';

class NodeSelectorMenu extends StatefulWidget {
  const NodeSelectorMenu({required this.vsNodeDataProvider, super.key});
  final VSNodeDataProvider vsNodeDataProvider;

  @override
  State<NodeSelectorMenu> createState() => _NodeSelectorMenuState();
}

class _NodeSelectorMenuState extends State<NodeSelectorMenu> {
  late Map<String, dynamic> nodeBuilders;
  List<Widget> sidebarWidgets = [];
  late dynamic currentEntries;
  List<Map<String, dynamic>> previousEntries = [];
  late String currentGroup;

  @override
  void initState() {
    super.initState();

    currentEntries = widget.vsNodeDataProvider.nodeBuildersMap.entries;
    currentGroup = 'Nodes';
    _buildSidebarWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      decoration: const BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsets.only(top: 8.0),
      child: IntrinsicWidth(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(),
              _divider(),
              ...sidebarWidgets,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (previousEntries.isNotEmpty)
            IconButton(
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(0),
                minimumSize: const Size(0, 0),
              ),
              onPressed: _navigateBack,
              icon: const Icon(Icons.arrow_back, size: 16),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Select $currentGroup",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Divider _divider() => const Divider(color: AppColors.grey200);

  void _navigateBack() {
    setState(() {
      sidebarWidgets = [];
      final previousGroup = previousEntries.removeLast();
      currentEntries = previousGroup.values.first;
      currentGroup = previousGroup.keys.first;
      _buildSidebarWidgets();
    });
  }

  void _buildSidebarWidgets() {
    for (final dynamic entry in currentEntries) {
      if (entry.value is Map) {
        sidebarWidgets.add(_buildGroupButton(entry));
      } else {
        sidebarWidgets.add(_buildNodeButton(entry));
      }
      sidebarWidgets.add(_divider());
    }
  }

  Widget _buildGroupButton(entry) {
    return TextButton(
      onPressed: () => _navigateToGroup(entry),
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
    );
  }

  void _navigateToGroup(entry) {
    setState(() {
      sidebarWidgets = [];
      previousEntries.add({currentGroup: currentEntries});
      currentEntries = entry.value.entries;
      currentGroup = entry.key;
      _buildSidebarWidgets();
    });
  }

  Widget _buildNodeButton(entry) {
    return Draggable(
      onDragEnd: (details) {
        widget.vsNodeDataProvider.createNodeFromSidebar(
          entry.value,
          offset: details.offset,
        );
      },
      feedback: Transform.scale(
        scale: 1 / widget.vsNodeDataProvider.viewportScale,
        child: Card(
          // key: _anchor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [Text(entry.key), const SizedBox(width: 100)],
            ),
          ),
        ),
      ),
      child: TextButton(
        onPressed: () =>
            widget.vsNodeDataProvider.createNodeFromSidebar(entry.value),
        child: Text(entry.key, style: const TextStyle(color: Colors.black)),
      ),
    );
  }
}
