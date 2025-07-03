import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParamNumInput extends StatefulWidget {
  const ParamNumInput({required this.parameter, super.key});

  final ParameterModel parameter;

  @override
  State<ParamNumInput> createState() => _ParamNumInputState();
}

class _ParamNumInputState extends State<ParamNumInput>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.parameter.value.toString());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant ParamNumInput oldWidget) {
    if (oldWidget.parameter.value != widget.parameter.value) {
      _controller.text = widget.parameter.value?.toString() ?? '';
      _validateInput(_controller.text);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIncrementButton(
          icon: Icons.add,
          onTap: _incrementValue,
        ),
        _buildTextField(),
        _buildIncrementButton(
          icon: Icons.remove,
          onTap: _decrementValue,
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return Expanded(
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 16),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          errorText: _errorText,
          errorStyle: const TextStyle(height: 0),
        ),
        onChanged: _validateAndUpdateValue,
      ),
    );
  }

  Widget _buildIncrementButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _animationController
                .forward()
                .then((_) => _animationController.reverse());
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndUpdateValue(String value) {
    setState(() {
      _validateInput(value);
      if (_errorText == null) {
        widget.parameter.value = widget.parameter.type == ParameterType.int
            ? int.tryParse(value) ?? 0
            : double.tryParse(value) ?? 0.0;
      }
    });
  }

  void _validateInput(String value) {
    if (value.isEmpty) {
      _errorText = 'Value cannot be empty';
    } else if (widget.parameter.type == ParameterType.int &&
        !value.contains(RegExp(r'^\d+$'))) {
      _errorText = 'Must be an integer';
    } else if (widget.parameter.type == ParameterType.double &&
        !value.contains(RegExp(r'^\d*\.?\d+$'))) {
      _errorText = 'Must be a valid number';
    } else {
      _errorText = null;
    }
  }

  void _incrementValue() {
    setState(() {
      if (widget.parameter.type == ParameterType.int) {
        widget.parameter.value = (widget.parameter.value as int) + 1;
      } else {
        widget.parameter.value = (widget.parameter.value as double) + 0.1;
      }
      _controller.text = widget.parameter.value.toString();
    });
  }

  void _decrementValue() {
    setState(() {
      if (widget.parameter.type == ParameterType.int) {
        if ((widget.parameter.value as int) > 0) {
          widget.parameter.value = (widget.parameter.value as int) - 1;
        }
      } else {
        if ((widget.parameter.value as double) > 0.1) {
          widget.parameter.value = (widget.parameter.value as double) - 0.1;
        }
      }
      _controller.text = widget.parameter.value.toString();
    });
  }
}
