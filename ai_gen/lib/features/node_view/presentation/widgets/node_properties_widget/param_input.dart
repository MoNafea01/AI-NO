import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/asset_paths.dart';
import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/node_properties_widget/param_num_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _titleRow(),
            _paramInput(),
          ],
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
    switch (widget.parameter.type) {
      case ParameterType.int:
      case ParameterType.double:
        return ParamNumInput(parameter: widget.parameter);
      case ParameterType.dropDownList:
        return ParamDropDownMenu(parameter: widget.parameter);
      default:
        return ParamTextField(parameter: widget.parameter);
    }
  }

  Row _titleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.parameter.name, style: AppTextStyles.black14w400),
        Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              setState(() {
                widget.parameter.value = widget.parameter.defaultValue;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: SvgPicture.asset(
                AssetsPaths.refreshIcon,
                width: 16,
                height: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
