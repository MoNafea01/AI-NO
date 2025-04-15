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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          isDense: true,
          value: widget.parameter.value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: ['l1', 'l2', 'elasticnet', 'none'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              widget.parameter.value = newValue!;
            });
          },
        ),
      ),
    );
  }
}
