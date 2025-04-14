import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/node_properties_widget/param_num_input.dart';
import 'package:flutter/material.dart';

import 'param_dropdown_menu.dart';
import 'param_text_field.dart';

class ParamInput extends StatefulWidget {
  const ParamInput({required this.parameter, super.key});
  final ParameterModel parameter;

  @override
  State<ParamInput> createState() => _ParamInputState();
}

class _ParamInputState extends State<ParamInput> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleRow(),
              const SizedBox(height: 16),
              _paramInput(),
            ],
          ),
        ),
      ),
    );
  }

  Container _paramInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: _selectParamWidget(),
    );
  }

  Widget _selectParamWidget() {
    if (widget.parameter.type == ParameterType.string) {
      return ParamDropDownMenu(parameter: widget.parameter);
    } else if (widget.parameter.type == ParameterType.number) {
      return ParamNumInput(parameter: widget.parameter);
    } else {
      return ParamTextField(parameter: widget.parameter);
    }
  }

  Row _titleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.parameter.name, style: AppTextStyles.black14w400),
        IconButton(
          splashRadius: 16,
          icon: const Icon(Icons.refresh, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            setState(() {
              widget.parameter.value = widget.parameter.defaultValue;
            });
          },
        ),
      ],
    );
  }
}
