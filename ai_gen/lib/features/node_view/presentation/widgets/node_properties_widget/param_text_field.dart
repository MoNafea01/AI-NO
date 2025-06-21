import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:flutter/material.dart';

class ParamTextField extends StatefulWidget {
  const ParamTextField({
    required this.parameter,
    super.key,
  });

  final ParameterModel parameter;

  @override
  State<ParamTextField> createState() => _ParamTextFieldState();
}

class _ParamTextFieldState extends State<ParamTextField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.parameter.value?.toString() ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant ParamTextField oldWidget) {
    if (oldWidget.parameter.value != widget.parameter.value) {
      setState(() {
        _controller.text = widget.parameter.value?.toString() ?? '';
        _validateInput(_controller.text);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minHeight: 32),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isFocused ? Colors.black : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            errorText: _errorText,
            errorStyle: const TextStyle(height: 0),
          ),
          onChanged: _validateAndUpdateValue,
          style: const TextStyle(fontSize: 16),
          maxLines: null,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  void _validateAndUpdateValue(String value) {
    setState(() {
      _validateInput(value);
      if (_errorText == null) {
        widget.parameter.value = value;
      }
    });
  }

  void _validateInput(String value) {
    if (value.isEmpty) {
      _errorText = 'Value cannot be empty';
    } else {
      _errorText = null;
    }
  }
}
