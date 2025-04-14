import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:ai_gen/core/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/node_properties_widget/param_num_input.dart';
import 'package:flutter/material.dart';

import 'param_dropdown_menu.dart';
import 'param_text_field.dart';

class ParamInput extends StatefulWidget {
  const ParamInput({
    required this.paramTitle,
    required this.defaultParamValue,
    this.type = 0,
    super.key,
  });

  final int type;
  final String paramTitle;
  final dynamic defaultParamValue;
  @override
  State<ParamInput> createState() => _ParamInputState();
}

class _ParamInputState extends State<ParamInput> {
  late dynamic defaultValue;

  @override
  void initState() {
    defaultValue = widget.defaultParamValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
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
    if (widget.type == 1) {
      return ParamDropDownMenu(value: defaultValue);
    } else if (widget.type == 2) {
      return ParamNumInput(value: defaultValue);
    } else {
      return ParamTextField(paramValue: defaultValue);
    }
  }

  Row _titleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.paramTitle, style: AppTextStyles.black14w400),
        IconButton(
          icon: const Icon(Icons.refresh, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            setState(() {
              defaultValue = widget.defaultParamValue;
            });
          },
        ),
      ],
    );
  }
}
