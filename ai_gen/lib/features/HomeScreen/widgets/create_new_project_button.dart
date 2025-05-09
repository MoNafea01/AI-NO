import 'package:flutter/material.dart';

import 'create_new_project_dialog.dart';

class CreateNewProjectButton extends StatelessWidget {
  const CreateNewProjectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const Dialog(
            child: CustomDialog(),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('New Project'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
