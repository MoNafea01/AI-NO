import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ParamMultiSelectMenu extends StatefulWidget {
  const ParamMultiSelectMenu({required this.parameter, super.key});

  final ParameterModel parameter;
  @override
  State<ParamMultiSelectMenu> createState() => _ParamMultiSelectMenuState();
}

class _ParamMultiSelectMenuState extends State<ParamMultiSelectMenu> {
  late final List<String> items;

  @override
  void initState() {
    items = widget.parameter.choices!.cast<String>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          isDense: true,
          items: items.map((item) {
            return _buildDropdownMenuItem(item);
          }).toList(),
          //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
          value: widget.parameter.value.isEmpty
              ? null
              : widget.parameter.value.last,
          onChanged: (value) {},
          selectedItemBuilder: (context) {
            return items.map(
              (item) {
                return Text(widget.parameter.value.join(', '));
              },
            ).toList();
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.only(left: 16, right: 16),
          ),

          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(String item) {
    return DropdownMenuItem(
      value: item,
      //disable default onTap to avoid closing menu when selecting an item
      enabled: false,
      child: StatefulBuilder(
        builder: (context, menuSetState) {
          final isSelected = widget.parameter.value.contains(item);
          return InkWell(
            onTap: () {
              isSelected
                  ? widget.parameter.value.remove(item)
                  : widget.parameter.value.add(item);
              //This rebuilds the StatefulWidget to update the button's text
              setState(() {});
              //This rebuilds the dropdownMenu Widget to update the check mark
              menuSetState(() {});
            },
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  if (isSelected)
                    const Icon(Icons.check_box_outlined)
                  else
                    const Icon(Icons.check_box_outline_blank),
                  const SizedBox(width: 16),
                  Text(item),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
