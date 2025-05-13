import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data/vs_node_data.dart';

/// A widget that represents the title of a node in the visual scripting interface.
///
/// This widget handles the visual representation and editing of a node's title,
/// including:
/// - Displaying the node's title
/// - Supporting inline editing of the title
/// - Managing focus and editing state
/// - Providing tooltips for additional information
class VSNodeTitle extends StatefulWidget {
  /// Creates a new [VSNodeTitle] instance.
  ///
  /// [data] is required and contains the node's data and state.
  /// [onTitleChange] is optional and called when the title is modified.
  const VSNodeTitle({
    required this.data,
    this.onTitleChange,
    super.key,
  });

  /// The data associated with this node
  final VSNodeData data;

  /// Optional callback that is called when the title is modified
  final VoidCallback? onTitleChange;

  @override
  State<VSNodeTitle> createState() => _VSNodeTitleState();
}

/// The state for the [VSNodeTitle] widget.
///
/// This state class manages the title's editing state, focus, and text input.
class _VSNodeTitleState extends State<VSNodeTitle> {
  /// Controller for managing the title text field
  late final TextEditingController _titleController;

  /// Focus node for managing the text field's focus state
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data.title);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VSNodeTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleRenamingStateChange();
  }

  /// Handles changes to the renaming state
  void _handleRenamingStateChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.data.isRenaming) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return wrapWithToolTip(
      toolTip: widget.data.toolTip,
      child: IntrinsicWidth(
        child: GestureDetector(
          child: _buildTitleTextField(),
        ),
      ),
    );
  }

  /// Builds the text field for editing the title
  Widget _buildTitleTextField() {
    return TextField(
      enabled: widget.data.isRenaming,
      controller: _titleController,
      focusNode: _focusNode,
      textAlign: TextAlign.center,
      style: AppTextStyles.nodeTitleTextStyle,
      decoration: _buildTextFieldDecoration(),
      onChanged: _handleTitleChange,
      onTapOutside: _handleTapOutside,
      onSubmitted: _handleTitleSubmit,
    );
  }

  /// Builds the decoration for the text field
  InputDecoration _buildTextFieldDecoration() {
    return InputDecoration(
      border: InputBorder.none,
      hintText: widget.data.type,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 5,
      ),
    );
  }

  /// Handles changes to the title text
  void _handleTitleChange(String input) {
    widget.onTitleChange?.call();
  }

  /// Handles taps outside the text field
  void _handleTapOutside(PointerDownEvent event) {
    widget.data.isRenaming = false;
    _titleController.text = widget.data.title;
    widget.onTitleChange?.call();
    setState(() {});
  }

  /// Handles submission of the title text
  void _handleTitleSubmit(String input) {
    widget.data.isRenaming = false;
    widget.data.title = input;
    widget.data.node?.displayName = input;
    widget.onTitleChange?.call();
    setState(() {});
  }
}
