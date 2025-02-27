import 'package:ai_gen/node_package/data/vs_node_data_provider.dart';
import 'package:flutter/material.dart';

class VSContextMenu extends StatefulWidget {
  ///Base context menu
  ///
  ///Used in [VSNodeView] to create new nodes
  const VSContextMenu({
    required this.nodeBuilders,
    super.key,
  });

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
    nodeBuilders = widget.nodeBuilders;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    final entries = nodeBuilders.entries;

    for (final entry in entries) {
      if (entry.value is Map) {
        widgets.add(
          TextButton(
            onPressed: () => setState(() {
              nodeBuilders = entry.value;
            }),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key,style: const TextStyle(
                    color: Colors.white,
                  ),
                  ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white, /////////////////////
                  size: 20,
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(TextButton(
          onPressed: () {
            final dataProvider = VSNodeDataProvider.of(context);
            dataProvider.createNodeFromContext(entry.value);
            dataProvider.closeContextMenu();
          },
          child: Text(entry.key),
        ));
      }
      if (entry.key != entries.last.key) {
        widgets.add(const Divider(color: Color.fromARGB(255, 14, 11, 11)));////
      }
    }

    return GestureDetector(
      child: Card(
        elevation: 2,
        color: const Color(0xff349CFE),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 160,
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
