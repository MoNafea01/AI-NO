import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:flutter/material.dart';

Widget buildTag({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onCopy,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
            fontFamily: AppConstants.appFontName,
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: onCopy,
          child: Icon(Icons.copy, size: 12, color: color),
        ),
      ],
    ),
  );
}
