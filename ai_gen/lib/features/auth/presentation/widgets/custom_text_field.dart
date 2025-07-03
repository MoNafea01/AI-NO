import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData? suffixIcon;
  final bool isPassword;
  final Function(String) onChanged;
  final TextInputType keyboardType;

  const CustomTextField({
    required this.hintText,
    required this.onChanged,
    this.suffixIcon,
    super.key,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.bluePrimaryColor),
        ),
        border: const OutlineInputBorder(),
        hintText: widget.hintText,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                //  color: AppColors.nodeViewSidebarDividerColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon != null
                ? Icon(
                    widget.suffixIcon,
                    //color: AppColors.nodeViewSidebarDividerColor,
                  )
                : null,
      ),
      onChanged: widget.onChanged,
    );
  }
}
