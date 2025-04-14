import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'param_input.dart';

class NodePropertiesCard extends StatelessWidget {
  const NodePropertiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final NodeModel? node =
        context.watch<GridNodeViewCubit>().activePropertiesNode;
    if (node == null) {
      return const SizedBox();
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: _decoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 38,
          children: [
            _infoTemplate(
              context,
              withClose: true,
              title: 'Parameters',
              children: _buildParametersList(node.params),
            ),
            _infoTemplate(
              context,
              title: 'Inputs',
              children: _buildInputsOutputsWidget(node.inputDots),
            ),
            _infoTemplate(
              context,
              title: 'Outputs',
              children: _buildInputsOutputsWidget(node.outputDots),
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

  Column _infoTemplate(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    bool withClose = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.textSecondary),
                if (withClose) _closeIcon(context),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _closeIcon(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context
              .read<GridNodeViewCubit>()
              .updateActiveNodePropertiesCard(null);
        },
        child: const Icon(Icons.close, size: 20),
      ),
    );
  }

  List<Widget> _buildParametersList(List<ParameterModel>? parameters) {
    return parameters == null || parameters.isEmpty
        ? _noneText()
        : parameters
            .map((parameter) => ParamInput(parameter: parameter))
            .toList();
  }

  List<Widget> _buildInputsOutputsWidget(List<String>? data) {
    return data == null || data.isEmpty
        ? _noneText()
        : data.map((info) {
            return Text(info, style: AppTextStyles.black16w400);
          }).toList();
  }

  List<Widget> _noneText() =>
      const [Text('None', style: AppTextStyles.black16w400)];
}
