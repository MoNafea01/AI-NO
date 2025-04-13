import 'package:flutter/material.dart';

class ParamDropDownMenu extends StatefulWidget {
  ParamDropDownMenu({required this.paramValue, super.key});

  String paramValue;
  @override
  State<ParamDropDownMenu> createState() => _ParamDropDownMenuState();
}

class _ParamDropDownMenuState extends State<ParamDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.paramValue,
            // isExpanded: true,

            icon: const Icon(Icons.keyboard_arrow_down),
            items: ['l1', 'l2', 'elasticnet asdf sdf sd f', 'none']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                widget.paramValue = newValue!;
              });
            },
          ),
        ),
      ),
    );
  }
}
