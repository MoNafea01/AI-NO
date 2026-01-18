import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyToClipboard(String text, String message, BuildContext context) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
    ),
  );
}
