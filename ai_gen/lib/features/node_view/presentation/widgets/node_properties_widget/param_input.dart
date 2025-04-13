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
  late dynamic selectedValue;

  @override
  void initState() {
    selectedValue = widget.defaultParamValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _titleRow(),
        _paramInput(),
      ],
    );
  }

  Container _paramInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: _selectParamWidget(),
    );
  }

  Widget _selectParamWidget() {
    if (widget.type == 1) {
      return ParamDropDownMenu(paramValue: selectedValue);
    } else if (widget.type == 2) {
      return ParamNumInput(value: selectedValue);
    } else {
      return ParamTextField(paramValue: selectedValue);
    }
  }

  Row _titleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.paramTitle),
        IconButton(
          icon: const Icon(Icons.refresh, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            setState(() {
              selectedValue = widget.defaultParamValue;
            });
          },
        ),
      ],
    );
  }
}
