import 'package:ai_gen/core/translation/translation_keys.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteEmptyProjectsDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteEmptyProjectsDialog({
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xffF2F2F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        TranslationKeys.deleteEmptyProjects.tr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      content: Text(
        TranslationKeys.areYouSureYouWantToDeleteEmptyProjects.tr,
        style: const TextStyle(
          color: Color(0xFF6B7280),
        ),
      ),
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bluePrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            TranslationKeys.cancel.tr,
            style: const TextStyle(
                //   color: Color(0xFF6B7280),
                ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(TranslationKeys.deleteEmpty.tr),
        ),
      ],
    );
  }
}
