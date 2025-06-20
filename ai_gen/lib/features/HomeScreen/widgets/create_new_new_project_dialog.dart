import 'package:ai_gen/features/HomeScreen/cubit/project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';




class CreateNewProjectButton extends StatelessWidget {
  const CreateNewProjectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showCreateProjectDialog(context),
      icon: SvgPicture.asset(
        'assets/icons/add.svg',
        width: 16,
        height: 16,
        // ignore: deprecated_member_use
        color: Colors.white,
      ),
      label: const Text('New Project'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NewProjectDialog(),
    );
  }
}

class NewProjectDialog extends StatefulWidget {
  const NewProjectDialog({super.key});

  @override
  State<NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Content curating app';
  String _selectedModel = 'Model name';

  final List<String> _projectTypes = [
    'Content curating app',
    'Design software',
    'Data prediction',
    'Productivity app',
    'Web app integrations',
    'Sales CRM',
    'Automation and workflow',
  ];

  final List<String> _modelOptions = [
    'Model name',
    'Basic model',
    'Standard model',
    'Advanced model',
    'Custom model',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          minWidth: 400,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create New Project',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Project Name
                  _buildLabel('Project Name'),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Enter project name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Project Description
                  _buildLabel('Description'),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Enter project description'),
                    minLines: 2,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Project Type
                  _buildLabel('Project Type'),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: _inputDecoration('Select project type'),
                    items: _projectTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Model Selection
                  _buildLabel('Model'),
                  DropdownButtonFormField<String>(
                    value: _selectedModel,
                    decoration: _inputDecoration('Select model'),
                    items: _modelOptions
                        .map((model) => DropdownMenuItem(
                              value: model,
                              child: Text(model),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedModel = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Create Project'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create a new project
      final newProject = ProjectItem(
        id: 'project-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        projectDescription: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'description',
        modelName: _selectedModel,
        modelDescription: 'Model description',
        type: _selectedType,
        typeDescription: 'Dataset description',
        dateCreated: DateTime.now(),
      );

      // Add project to the state
      context.read<ProjectCubit>().createProject(newProject);

      // Close the dialog
      Navigator.of(context).pop();

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Project "${_nameController.text}" created successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
