import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:flutter/material.dart';

class NodeInputsOutputs extends StatelessWidget {
  const NodeInputsOutputs({
    super.key,
    this.inputs = const ['None'],
    this.outputs = const ['None'],
  });

  final List<String> inputs;
  final List<String> outputs;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoWidget(title: 'Inputs', info: inputs),
        const SizedBox(height: 19),
        _infoWidget(title: 'Outputs', info: outputs),
      ],
    );
  }

  Column _infoWidget({required String title, required List<String> info}) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.textSecondary),
        const SizedBox(height: 8),
        ...inputs.map((info) {
          return Text(info, style: AppTextStyles.black16w400);
        }),
      ],
    );
  }
}
