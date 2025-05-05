import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:flutter/material.dart';

class ParamTextField extends StatefulWidget {
  const ParamTextField({required this.parameter, super.key});

  final ParameterModel parameter;
  @override
  State<ParamTextField> createState() => _ParamTextFieldState();
}

class _ParamTextFieldState extends State<ParamTextField> {
  late final TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.parameter.value.toString());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ParamTextField oldWidget) {
    controller.text = widget.parameter.value.toString();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: Center(
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
          onChanged: (value) {
            setState(() {
              widget.parameter.value = value;
            });
          },
        ),
      ),
    );
  }
}
