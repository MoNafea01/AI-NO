import 'package:flutter/material.dart';

class DeleteEmptyProjectsDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteEmptyProjectsDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Delete Empty Projects',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
      content: const Text(
        'Are you sure you want to delete all empty projects? This will remove all projects that have no model or dataset assigned. This action cannot be undone.',
        style: TextStyle(
          color: Color(0xFF6B7280),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF6B7280),
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
          ),
          child: const Text('Delete Empty'),
        ),
      ],
    );
  }
}
