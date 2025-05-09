import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    required this.controller,
    this.labelText,
    this.isRequired = true,
    this.suffixIcon,
    this.hintText,
    super.key,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (isRequired && value != null && value.isEmpty) {
          return 'Please enter a $labelText';
        }
        return null;
      },
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        isDense: true,
        alignLabelWithHint: true,
        label: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(labelText ?? ""),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintText: hintText,
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
