import 'package:flutter/material.dart';

Widget buildRequirement(String text, bool isMet) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isMet ? Colors.green : Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
