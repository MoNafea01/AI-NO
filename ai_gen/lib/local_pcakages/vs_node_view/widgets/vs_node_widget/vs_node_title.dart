import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data/vs_node_data.dart';
import '../../data/vs_node_data_provider.dart';

enum PopupOptions { rename, delete }

class VSNodeTitle extends StatefulWidget {
  ///Base node title widget
  ///
  ///Used in [VSNode] to build the title
  const VSNodeTitle({required this.data, super.key});

  final VSNodeData data;

  @override
  State<VSNodeTitle> createState() => _VSNodeTitleState();
}

class _VSNodeTitleState extends State<VSNodeTitle> {
  final titleController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.data.title;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isRenaming) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        wrapWithToolTip(
          toolTip: widget.data.toolTip,
          child: IntrinsicWidth(
            child: GestureDetector(
              onDoubleTap: () => setState(() => widget.data.isRenaming = true),
              child: TextField(
                contextMenuBuilder: (_, editableTextState) {
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: [
                      ContextMenuButtonItem(
                        onPressed: () => setState(() {
                          widget.data.isRenaming = true;
                          editableTextState.hideToolbar();
                        }),
                        label: 'Rename',
                      ),
                      // ...editableTextState.contextMenuButtonItems,
                    ],
                  );
                },
                readOnly: !widget.data.isRenaming,
                controller: titleController,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.data.type,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                ),
                onTapOutside: (event) => setState(() {
                  widget.data.isRenaming = false;
                  titleController.text = widget.data.title;
                }),
                onSubmitted: (input) => widget.data.title = input,
              ),
            ),
          ),
        ),

        // _buildPopupMenuButton(context),
      ],
    );
  }

  PopupMenuButton<PopupOptions> _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton<PopupOptions>(
      tooltip: "",
      child: const Icon(Icons.more_vert, size: 20, color: Colors.white),
      onSelected: (value) {
        switch (value) {
          case PopupOptions.rename:
            setState(() => widget.data.isRenaming = true);
            break;
          case PopupOptions.delete:
            widget.data.deleteNode?.call();
            VSNodeDataProvider.of(context).removeNodes([widget.data]);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<PopupOptions>(
          value: PopupOptions.rename,
          child: Text("Rename"),
        ),
        const PopupMenuItem<PopupOptions>(
          value: PopupOptions.delete,
          child: Text("Delete"),
        ),
      ],
    );
  }
}
