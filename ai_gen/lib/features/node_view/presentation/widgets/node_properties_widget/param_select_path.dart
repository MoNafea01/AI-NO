import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/reusable_widgets/pick_file_text_field.dart';
import 'package:flutter/material.dart';

class ParamSelectPath extends StatefulWidget {
  const ParamSelectPath({required this.parameter, super.key});

  final ParameterModel parameter;
  @override
  State<ParamSelectPath> createState() => _ParamSelectPathState();
}

class _ParamSelectPathState extends State<ParamSelectPath> {
  late final TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.parameter.value.toString());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ParamSelectPath oldWidget) {
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
    return PickfileTextField(
      controller: controller,
      allowedExtensions: widget.parameter.allowedExtensions!.cast<String>(),
      onFilePicked: () {
        widget.parameter.value = controller.text;
      },
    );
  }
}
