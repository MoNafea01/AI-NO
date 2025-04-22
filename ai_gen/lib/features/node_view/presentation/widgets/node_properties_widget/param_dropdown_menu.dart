import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:flutter/material.dart';

class ParamDropDownMenu extends StatefulWidget {
  const ParamDropDownMenu({required this.parameter, super.key});

  final ParameterModel parameter;
  @override
  State<ParamDropDownMenu> createState() => _ParamDropDownMenuState();
}

class _ParamDropDownMenuState extends State<ParamDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    print(widget.parameter.value);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          isDense: true,
          value: widget.parameter.value is List
              ? widget.parameter.value[0].toString()
              : widget.parameter.value.toString(),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: widget.parameter.choices?.map((value) {
            return DropdownMenuItem<String>(
              value: value.toString(),
              child: Text(value.toString()),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              widget.parameter.value = newValue ?? widget.parameter.value;
            });
          },
        ),
      ),
    );
  }
}
