// import 'package:flutter/material.dart';

// Widget buildPasswordField({
//   required String label,
//   required TextEditingController controller,
//   required bool obscureText,
//   required VoidCallback onToggleVisibility,
//   IconData? icon,
//   void Function(String)? onChanged,
// }) {
//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       onChanged: onChanged,
//       style: const TextStyle(fontSize: 16),
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: icon != null
//             ? Icon(icon, color: Theme.of(context).primaryColor)
//             : null,
//         suffixIcon: IconButton(
//           icon: Icon(
//             obscureText ? Icons.visibility_off : Icons.visibility,
//             color: Theme.of(context).primaryColor.withOpacity(0.7),
//           ),
//           onPressed: onToggleVisibility,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide:
//               BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 1),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         filled: true,
//         fillColor: Colors.white,
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return 'This field is required';
//         if (controller == _confirmPasswordController &&
//             value != _newPasswordController.text) {
//           return 'Passwords do not match';
//         }
//         if (controller == _newPasswordController && value.length < 6) {
//           return 'Password must be at least 6 characters';
//         }
//         return null;
//       },
//     ),
//   );
// }
