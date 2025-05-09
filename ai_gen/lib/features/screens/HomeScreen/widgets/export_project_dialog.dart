import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/reusable_widgets/custom_dialog.dart';
import 'package:ai_gen/core/reusable_widgets/custom_text_form_field.dart';
import 'package:ai_gen/core/services/app_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExportProjectDialog extends StatefulWidget {
  const ExportProjectDialog({this.projectModel, super.key});

  //TODO: this should be made required
  final ProjectModel? projectModel;
  @override
  State<ExportProjectDialog> createState() => _ExportProjectDialogState();
}

class _ExportProjectDialogState extends State<ExportProjectDialog> {
  late final TextEditingController _projectPathController;
  late final TextEditingController _projectFormatController;
  late final TextEditingController _projectNameController;
  late final TextEditingController _projectPasswordController;

  @override
  void initState() {
    super.initState();
    _projectNameController =
        TextEditingController(text: widget.projectModel?.name ?? "");
    _projectPathController = TextEditingController();
    _projectFormatController = TextEditingController(text: "ainoprj");
    _projectPasswordController = TextEditingController();

    _projectFormatController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _projectPathController.dispose();
    _projectFormatController.dispose();
    _projectNameController.dispose();
    _projectPasswordController.dispose();
    super.dispose();
  }

  void _onExportPressed() async {
    try {
      final String message = await AppServices().exportProject(
        projectId: widget.projectModel!.id!,
        fileName: _projectNameController.text,
        filePath: _projectPathController.text,
        format: _projectFormatController.text,
        password: _projectPasswordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onCancelPressed() {
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dialogTitle: "Export Project",
      submitButtonText: "Export",
      cancelButtonText: "Cancel",
      onSubmit: _onExportPressed,
      onCancel: _onCancelPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            controller: _projectNameController,
            labelText: 'File Name',
          ),
          const SizedBox(height: 24),
          CustomTextFormField(
            controller: _projectPathController,
            labelText: 'Export Location',
            suffixIcon: _pickFileIcon(),
          ),
          const SizedBox(height: 10),
          FormatDropdownMenu(controller: _projectFormatController),
          _projectFormatController.text == "ainoprj"
              ? Column(
                  children: [
                    const SizedBox(height: 24),
                    CustomTextFormField(
                      controller: _projectPasswordController,
                      labelText: 'Optional Password',
                      isRequired: false,
                      hintText: "No recovery (we don't have time)",
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  IconButton _pickFileIcon() {
    return IconButton(
      onPressed: () async {
        await _pickFile();
      },
      style: IconButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      icon: const Icon(Icons.folder_open, color: Colors.black),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      lockParentWindow: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      _projectPathController.text = file.path ?? '';
    }
  }
}

class FormatDropdownMenu extends StatefulWidget {
  const FormatDropdownMenu({required this.controller, super.key});

  final TextEditingController controller;
  @override
  State<FormatDropdownMenu> createState() => _FormatDropdownMenuState();
}

class _FormatDropdownMenuState extends State<FormatDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "File Format",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                value: widget.controller.text,
                isExpanded: true,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: ["ainoprj", "json"].map((value) {
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  setState(() => widget.controller.text = newValue);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
