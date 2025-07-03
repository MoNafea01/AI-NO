import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/reusable_widgets/custom_dialog.dart';
import 'package:ai_gen/core/reusable_widgets/custom_text_form_field.dart';
import 'package:ai_gen/features/node_view/presentation/node_view.dart';
import 'package:flutter/material.dart';

class CreateNewProjectDialog extends StatefulWidget {
  const CreateNewProjectDialog({super.key});

  @override
  State<CreateNewProjectDialog> createState() => _CreateNewProjectDialogState();
}

class _CreateNewProjectDialogState extends State<CreateNewProjectDialog> {
  late final TextEditingController _projectNameController;
  late final TextEditingController _projectDescriptionController;

  @override
  void initState() {
    _projectNameController = TextEditingController();
    _projectDescriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }

  void _onCreatePressed() {
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

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dialogTitle: "New project",
      submitButtonText: "Create",
      onSubmit: _onCreatePressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          CustomTextFormField(
            controller: _projectNameController,
            labelText: 'Project Name',
          ),
          CustomTextFormField(
            controller: _projectDescriptionController,
            labelText: 'Project Description',
          ),
        ],
      ),
    );
  }
}
