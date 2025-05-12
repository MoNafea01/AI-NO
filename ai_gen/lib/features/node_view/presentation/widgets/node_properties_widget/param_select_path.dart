import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/utils/helper/helper.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ParamSelectPath extends StatefulWidget {
  const ParamSelectPath({required this.parameter, super.key});

  final ParameterModel parameter;

  @override
  State<ParamSelectPath> createState() => _ParamSelectPathState();
}

class _ParamSelectPathState extends State<ParamSelectPath>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;

  late final FocusNode _focusNode;
  int _selectedIndex = 0;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.parameter.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void didUpdateWidget(covariant ParamSelectPath oldWidget) {
    if (oldWidget.parameter.value != widget.parameter.value) {
      _controller.text = widget.parameter.value?.toString() ?? '';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggleSwitch(),
        _buildPathField(),
      ],
    );
  }

  Widget _buildPathField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minHeight: 32),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isFocused ? AppColors.bluePrimaryColor : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: AppTextStyles.black16w400,
        expands: false,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        onTap: () async {
          if (_controller.text.isNotEmpty) return;
          await _pickFile();
        },
        decoration: InputDecoration(
          hintText: 'Pick a file or directory',
          hintStyle: AppTextStyles.black16w400.copyWith(color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // suffixIcon: _buildSuffixIcon(),
        ),
        onChanged: _onFilePicked,
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return ToggleSwitch(
      minWidth: 900.0,
      fontSize: 14,
      iconSize: 14,
      initialLabelIndex: _selectedIndex,
      cornerRadius: 8,
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey[400],
      inactiveFgColor: Colors.black,
      activeBgColor: const [AppColors.bluePrimaryColor],
      customTextStyles: const [],
      animate: true,
      animationDuration: 400,
      totalSwitches: 2,
      labels: const ['File', 'Directory'],
      icons: const [FontAwesomeIcons.file, FontAwesomeIcons.folder],
      onToggle: (index) async {
        if (index != null) {
          setState(() {
            _selectedIndex = index;
          });
          await _pickFile();
        }
      },
    );
  }

  Future<void> _pickFile() async {
    String? path;
    if (_selectedIndex == 0) {
      path = await Helper.pickFile(
        allowedExtensions: widget.parameter.allowedExtensions!.cast<String>(),
      );
    } else {
      path = await Helper.pickDirectory();
    }

    if (path != null) {
      _controller.text = path;
      _onFilePicked(path);
    }
  }

  void _onFilePicked(String value) {
    setState(() {
      widget.parameter.value = value;
    });
  }
}
