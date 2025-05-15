import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/reusable_widgets/custom_dialog.dart';
import 'package:ai_gen/core/reusable_widgets/custom_text_form_field.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';

class CreateNewProjectDialog extends StatefulWidget {
  const CreateNewProjectDialog({
    this.dialogTitle,
    this.submitButtonText,
    this.cancelButtonText,
    this.onSubmit,
    this.onCancel,
    this.onDispose,
    this.dialogContent,
    super.key,
  });

  final String? dialogTitle;
  final String? submitButtonText;
  final String? cancelButtonText;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final VoidCallback? onDispose;
  final Widget? dialogContent;

  @override
  State<CreateNewProjectDialog> createState() => _CreateNewProjectDialogState();
}

class _CreateNewProjectDialogState extends State<CreateNewProjectDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _projectNameController;
  late final TextEditingController _projectDescriptionController;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _projectNameController = TextEditingController();
    _projectDescriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    widget.onDispose?.call();
    super.dispose();
  }

  void _onCreatePressed() {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit?.call();

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
    if (!mounted) return;
    widget.onCancel?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dialogTitle: "Create New Project",
      submitButtonText: "Create",
      onSubmit: _onCreatePressed,
      onCancel: _onCancelPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          const Text(
            'New project',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          widget.dialogContent ?? const SizedBox(),
          CustomTextFormField(
            controller: _projectNameController,
            labelText: 'Project name',
          ),
          CustomTextFormField(
            controller: _projectDescriptionController,
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
    );
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
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            widget.dialogContent ?? const SizedBox(),
            CustomTextFormField(
              controller: _projectNameController,
              labelText: 'Project name',
            ),
            CustomTextFormField(
              controller: _projectDescriptionController,
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
