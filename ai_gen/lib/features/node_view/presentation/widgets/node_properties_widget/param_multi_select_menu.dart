import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ParamMultiSelectMenu extends StatefulWidget {
  const ParamMultiSelectMenu({
    required this.parameter,
    super.key,
  });

  final ParameterModel parameter;

  @override
  State<ParamMultiSelectMenu> createState() => _ParamMultiSelectMenuState();
}

class _ParamMultiSelectMenuState extends State<ParamMultiSelectMenu>
    with SingleTickerProviderStateMixin {
  late final List<String> _items;
  late final AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _items = widget.parameter.choices!.cast<String>();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minHeight: 32),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isExpanded ? Colors.black : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          isDense: true,
          items: _items.map((item) => _buildDropdownMenuItem(item)).toList(),
          value: widget.parameter.value.isEmpty
              ? null
              : widget.parameter.value.last,
          onChanged: (value) {},
          selectedItemBuilder: (context) {
            return _items.map(
              (item) {
                return Text(
                  widget.parameter.value.join(', '),
                  style: AppTextStyles.black16w400,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ).toList();
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.only(left: 16, right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.zero,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            offset: const Offset(0, -4),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: MaterialStateProperty.all(6),
              thumbVisibility: MaterialStateProperty.all(true),
            ),
          ),
          onMenuStateChange: (isOpen) {
            setState(() {
              _isExpanded = isOpen;
            });
          },
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(String item) {
    return DropdownMenuItem(
      value: item,
      enabled: false,
      child: StatefulBuilder(
        builder: (context, menuSetState) {
          final isSelected = widget.parameter.value.contains(item);
          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  widget.parameter.value.remove(item);
                } else {
                  widget.parameter.value.add(item);
                }
              });
              menuSetState(() {});
            },
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      key: ValueKey(isSelected),
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.black16w400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
