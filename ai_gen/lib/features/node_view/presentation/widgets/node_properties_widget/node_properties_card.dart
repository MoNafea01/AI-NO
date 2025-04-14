import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:flutter/material.dart';

import 'param_input.dart';

class NodePropertiesCard extends StatelessWidget {
  const NodePropertiesCard({required this.node, super.key});

  final NodeModel node;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            _infoTemplate(
              title: 'Parameters',
              child: _buildParametersList(node.params),
            ),
            _infoTemplate(
              title: 'Inputs',
              child: _buildInputsOutputsWidget(node.inputDots),
            ),
            _infoTemplate(
              title: 'Outputs',
              child: _buildInputsOutputsWidget(node.outputDots),
            ),
          ],
        ),
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

  Column _infoTemplate({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.textSecondary),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: child,
        ),
      ],
    );
  }

  Widget _buildParametersList(List<ParameterModel>? parameters) {
    return parameters == null || parameters.isEmpty
        ? _noneText()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: parameters
                .map((parameter) => ParamInput(parameter: parameter))
                .toList(),
          );
  }

  Widget _buildInputsOutputsWidget(List<String>? data) {
    return data == null || data.isEmpty
        ? _noneText()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...data.map((info) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(info, style: AppTextStyles.black16w400),
                );
              }),
            ],
          );
  }

  Widget _noneText() => const Text('None', style: AppTextStyles.black16w400);
}
