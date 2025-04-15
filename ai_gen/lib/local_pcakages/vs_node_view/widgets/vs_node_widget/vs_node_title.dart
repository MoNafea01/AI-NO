import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data/vs_node_data.dart';

enum PopupOptions { rename, delete }

class VSNodeTitle extends StatefulWidget {
  const VSNodeTitle({required this.data, this.onTitleChange, super.key});

  final VSNodeData data;
  final VoidCallback? onTitleChange;
  @override
  State<VSNodeTitle> createState() => _VSNodeTitleState();
}

class _VSNodeTitleState extends State<VSNodeTitle> {
  late final TextEditingController titleController;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.data.title);
    focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant VSNodeTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data.isRenaming) {
        focusNode.requestFocus();
      } else {
        focusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        wrapWithToolTip(
          toolTip: widget.data.toolTip,
          child: IntrinsicWidth(
            child: GestureDetector(
              onDoubleTap: () => setState(() => widget.data.isRenaming = true),
              child: TextField(
                contextMenuBuilder: _textFieldMenuBuilder,
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
                onChanged: (input) {
                  widget.onTitleChange?.call();
                },
                onTapOutside: (event) {
                  widget.data.isRenaming = false;
                  titleController.text = widget.data.title;
                  widget.onTitleChange?.call();
                  setState(() {});
                },
                onSubmitted: (input) {
                  widget.data.isRenaming = false;
                  widget.data.title = input;
                  widget.data.node?.displayName = input;
                  widget.onTitleChange?.call();

                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textFieldMenuBuilder(_, editableTextState) {
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
      ],
    );
  }
}
