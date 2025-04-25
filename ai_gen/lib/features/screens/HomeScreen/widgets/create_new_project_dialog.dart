import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';

class CreateNewProjectDialog extends StatefulWidget {
  const CreateNewProjectDialog({super.key});

  @override
  State<CreateNewProjectDialog> createState() => _CreateNewProjectDialogState();
}

class _CreateNewProjectDialogState extends State<CreateNewProjectDialog> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }

  void _onCreatePressed() {
    if (!_formKey.currentState!.validate()) return;

    final String projectName = _projectNameController.text;
    final String projectDescription = _projectDescriptionController.text;

    Navigator.pop(context);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => NodeView(
          projectModel: ProjectModel(
            name: projectName,
            description: projectDescription,
          ),
        ),
      ),
    );
  }

  void _onCancelPressed() {
    if (mounted) Navigator.pop(context);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            const Text(
              'New project',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            CustomTextField(
              projectNameController: _projectNameController,
              labelText: 'Project name',
            ),
            CustomTextField(
              projectNameController: _projectDescriptionController,
              labelText: 'Project description',
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _onCancelPressed,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _onCreatePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {required this.projectNameController, this.labelText, super.key});

  final TextEditingController projectNameController;

  final String? labelText;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) =>
          value != null && value.isEmpty ? 'Please enter a $labelText' : null,
      controller: projectNameController,
      decoration: InputDecoration(
        label: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(labelText ?? ""),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
