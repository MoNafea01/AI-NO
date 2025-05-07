import 'package:ai_gen/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomMenuItem extends PopupMenuEntry<String> {
  final String value;
  final VoidCallback? onTap;

  const CustomMenuItem(
    this.value, {
    required this.child,
    this.onTap,
    this.itemHeight = 40,
    this.childAlignment = Alignment.center,
    super.key,
  });

  final double itemHeight;
  final Widget child;
  final Alignment childAlignment;

  @override
  double get height => itemHeight;

  @override
  bool represents(String? value) => value == this.value;

  @override
  State<StatefulWidget> createState() => _CustomMenuItemState();
}

class _CustomMenuItemState extends State<CustomMenuItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onTap?.call();
      },
      splashColor: AppColors.bluePrimaryColor,
      hoverColor: AppColors.bluePrimaryColor,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        alignment: widget.childAlignment,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: widget.child,
      ),
    );
  }
}
