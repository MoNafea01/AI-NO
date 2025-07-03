import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {required this.projectNameController, this.labelText, super.key});

  final TextEditingController projectNameController;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) =>
          value != null && value.isEmpty ? 'Please enter a $labelText' : null,
      controller: projectNameController,
      decoration: InputDecoration(
        label: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(labelText ?? ""),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
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
