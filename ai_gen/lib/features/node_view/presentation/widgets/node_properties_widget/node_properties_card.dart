import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:flutter/material.dart';

import 'param_dropdown_menu.dart';

class ParametersWidget extends StatelessWidget {
  const ParametersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, minWidth: 150),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.8),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parameters', style: AppTextStyles.titleGrey16Bold),
            SizedBox(height: 4),
            // ParamInput(paramTitle: 'penalty', defaultParamValue: 'l2', type: 1),
            ParamDropDownMenu(paramValue: 'l2'),
            // SizedBox(height: 10),
            // ParamInput(paramTitle: 'C', defaultParamValue: 1.0, type: 2),
            // SizedBox(height: 16),
            // InputsOutputs(),
          ],
        ),
      ),
    );
  }
}

class InputsOutputs extends StatelessWidget {
  const InputsOutputs({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inputs',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Text('model'),
        SizedBox(height: 16),

        // Outputs section
        Text(
          'Outputs',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Text('None'),
      ],
    );
  }
}
