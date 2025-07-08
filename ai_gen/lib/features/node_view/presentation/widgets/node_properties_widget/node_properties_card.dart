import 'package:ai_gen/core/models/node_model/node_model.dart';
import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'param_input.dart';

class NodePropertiesCard extends StatelessWidget {
  const NodePropertiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridNodeViewCubit, GridNodeViewState>(
      builder: (context, state) {
        final node = context.read<GridNodeViewCubit>().activePropertiesNode;
        if (node == null) return const SizedBox();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: CardContainer(
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .6,
                  ),
                  child: SingleChildScrollView(
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 38,
                        children: [
                          if (node.params.isNotEmpty)
                            PropertiesSection(
                              title: 'Parameters',
                              children: _buildParametersList(node.params),
                            ),
                          if (node.inputDots?.isNotEmpty ?? false)
                            PropertiesSection(
                              title: 'Inputs',
                              children: _buildInputsOutputsWidget(
                                  node.inputDots ?? []),
                            ),
                          if (node.outputDots?.isNotEmpty ?? false)
                            PropertiesSection(
                              title: 'Outputs',
                              children: _buildInputsOutputsWidget(
                                node.outputDots ?? [],
                              ),
                            ),
                          if (node.payload != null)
                            PropertiesSection(
                              title: 'Payload',
                              children: _buildPayloadWidget(node),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  right: 0,
                  child: CloseButton(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPayloadWidget(NodeModel node) {
    return [
      Text(
        "${node.payload}",
        style: AppTextStyles.black16w400,
      )
    ];
  }

  List<Widget> _buildParametersList(List<ParameterModel> parameters) {
    return [
      IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: parameters
              .map((parameter) => ParamInput(parameter: parameter))
              .toList(),
        ),
      ),
    ];
  }

  List<Widget> _buildInputsOutputsWidget(List<String> data) {
    return data.map((info) {
      return Text(
        info,
        style: AppTextStyles.black16w400,
        overflow: TextOverflow.ellipsis,
      );
    }).toList();
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;

  const CardContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class PropertiesSection extends StatelessWidget {
  const PropertiesSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200),
          child: Text(
            title,
            style: AppTextStyles.textSecondary,
            overflow: TextOverflow.ellipsis,
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
}

class CloseButton extends StatelessWidget {
  const CloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.bluePrimaryColor,
          onTap: () {
            context
                .read<GridNodeViewCubit>()
                .updateActiveNodePropertiesCard(null);
          },
          child: const Icon(Icons.close, size: 20),
        ),
      ),
    );
  }
}
