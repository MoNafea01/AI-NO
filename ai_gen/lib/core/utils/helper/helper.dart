import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

abstract class Helper {
  static List<num> parseIntList(dynamic text) {
    return text
        .toString()
        .replaceAll("[", "")
        .replaceAll("]", "")
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
  }

  static Future<String?> pickFile({List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: allowedExtensions,
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      lockParentWindow: true,
    );

    return result?.files.first.path;
  }

  static Future<String?> pickDirectory() async {
    return await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
    );
  }

  static Future<dynamic> showDialogHelper(
    BuildContext context,
    Widget customDialog,
  ) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(child: customDialog),
    );
  }
}
