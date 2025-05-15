import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    required this.controller,
    this.labelText,
    this.isRequired = true,
    this.suffixIcon,
    this.hintText,
    this.enabled = true,
    this.isPassword = false,
    super.key,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final Widget? suffixIcon;
  final bool enabled;
  final bool isPassword;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool isPasswordVisible;

  @override
  void initState() {
    super.initState();
    isPasswordVisible = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      obscureText: isPasswordVisible,
      validator: (value) {
        if (widget.isRequired && value != null && value.isEmpty) {
          return 'Please enter ${widget.labelText}';
        }
        return null;
      },
      controller: widget.controller,
      decoration: InputDecoration(
        suffixIcon: widget.suffixIcon ??
            (widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() => isPasswordVisible = !isPasswordVisible);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  )
                : null),
        isDense: true,
        alignLabelWithHint: true,
        label: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(widget.labelText ?? ""),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
