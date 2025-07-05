// ignore_for_file: deprecated_member_use

import 'package:ai_gen/core/utils/app_constants.dart';
import 'package:flutter/material.dart';

Widget buildTag({
  required String icon,
  required String label,
  required Color color,
  required VoidCallback onCopy,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xff999999)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          icon,
          color: Colors.black,
          width: 16,
          height: 16,
        ),
        // Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
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
