import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/node_properties_widget/param_input.dart';
import 'package:flutter/material.dart';

import 'params_inputs_outputs.dart';

class ParametersWidget extends StatelessWidget {
  const ParametersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Parameters ', style: AppTextStyles.textSecondary),
          ParamInput(paramTitle: 'penalty', defaultParamValue: 'l2', type: 1),
          ParamInput(paramTitle: 'C', defaultParamValue: 1.0, type: 2),
          SizedBox(height: 19),
          NodeInputsOutputs(),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.8),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
