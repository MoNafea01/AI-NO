import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/core/utils/themes/asset_paths.dart';
import 'package:ai_gen/core/utils/themes/textstyles.dart';
import 'package:ai_gen/features/node_view/presentation/widgets/node_properties_widget/param_num_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'param_dropdown_menu.dart';
import 'param_multi_select_menu.dart';
import 'param_select_path.dart';
import 'param_text_field.dart';

class ParamInput extends StatefulWidget {
  const ParamInput({required this.parameter, super.key});
  final ParameterModel parameter;

  @override
  State<ParamInput> createState() => _ParamInputState();
}

class _ParamInputState extends State<ParamInput>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  Key _paramWidgetKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _buildTitleRow(),
            _buildParamInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildParamInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: _buildParamWidget(),
    );
  }

  Widget _buildParamWidget() {
    switch (widget.parameter.type) {
      case ParameterType.int:
      case ParameterType.double:
        return ParamNumInput(key: _paramWidgetKey, parameter: widget.parameter);
      case ParameterType.dropDownList:
        return ParamDropDownMenu(
            key: _paramWidgetKey, parameter: widget.parameter);
      case ParameterType.listString:
        return ParamMultiSelectMenu(
            key: _paramWidgetKey, parameter: widget.parameter);
      case ParameterType.path:
        return ParamSelectPath(
            key: _paramWidgetKey, parameter: widget.parameter);
      default:
        return ParamTextField(
            key: _paramWidgetKey, parameter: widget.parameter);
    }
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.parameter.name,
            style: AppTextStyles.black14w400,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildResetButton(),
      ],
    );
  }

  Widget _buildResetButton() {
    final bool hasValue = widget.parameter.value != null &&
        (widget.parameter.value is String
            ? (widget.parameter.value as String).isNotEmpty
            : true) &&
        (widget.parameter.value is List
            ? (widget.parameter.value as List).isNotEmpty
            : true);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: _handleReset,
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          child: Padding(
            padding: const EdgeInsets.all(4.0),

            //refreshIcon
            child: SvgPicture.asset(
              AssetsPaths.refreshIcon,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                hasValue ? Colors.black : Colors.grey[700]!,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleReset() {
    setState(() {
      widget.parameter.resetValue();
      _paramWidgetKey = UniqueKey();
    });
  }
}
