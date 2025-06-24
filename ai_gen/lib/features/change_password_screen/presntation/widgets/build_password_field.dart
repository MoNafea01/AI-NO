import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16),
    ),
  );
}

Widget buildPasswordField(TextEditingController controller, bool visible,
    VoidCallback toggleVisibility) {
  return TextField(
    controller: controller,
    obscureText: !visible,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      suffixIcon: IconButton(
        icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
        onPressed: toggleVisibility,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1),
      ),
    ),
  );
}
