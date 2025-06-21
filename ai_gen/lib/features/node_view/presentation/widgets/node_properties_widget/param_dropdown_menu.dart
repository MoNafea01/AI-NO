import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';

class ParamDropDownMenu extends StatefulWidget {
  const ParamDropDownMenu({
    required this.parameter,
    super.key,
  });

  final ParameterModel parameter;

  @override
  State<ParamDropDownMenu> createState() => _ParamDropDownMenuState();
}

class _ParamDropDownMenuState extends State<ParamDropDownMenu>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

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
        child: DropdownButton<String>(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          isDense: true,
          value: _getCurrentValue(),
          isExpanded: true,
          icon: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isExpanded ? 0.5 : 0,
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
            ),
          ),
          items: _buildDropdownItems(),
          onChanged: _handleValueChanged,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          style: AppTextStyles.black16w400,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(6),
          elevation: 4,
        ),
      ),
    );
  }

  String _getCurrentValue() {
    if (widget.parameter.value is List) {
      return widget.parameter.value[0].toString();
    }
    return widget.parameter.value.toString();
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return widget.parameter.choices?.map((value) {
          return DropdownMenuItem<String>(
            value: value.toString(),
            child: Text(
              value.toString(),
              style: AppTextStyles.black16w400,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList() ??
        [];
  }

  void _handleValueChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        widget.parameter.value = newValue;
        _isExpanded = false;
      });
    }
  }
}
