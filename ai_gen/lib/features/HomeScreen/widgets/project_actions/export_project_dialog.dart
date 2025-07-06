import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/utils/reusable_widgets/custom_dialog.dart';
import 'package:ai_gen/core/utils/reusable_widgets/custom_text_form_field.dart';
import 'package:ai_gen/core/utils/reusable_widgets/pick_folder_icon.dart';
import 'package:ai_gen/core/data/network/services/interfaces/project_services_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ExportProjectDialog extends StatefulWidget {
  const ExportProjectDialog({this.projectModel, super.key});

  //TODO: this should be made required
  final ProjectModel? projectModel;
  @override
  State<ExportProjectDialog> createState() => _ExportProjectDialogState();
}

class _ExportProjectDialogState extends State<ExportProjectDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _projectPathController;
  late final TextEditingController _projectFormatController;
  late final TextEditingController _projectNameController;
  late final TextEditingController _projectPasswordController;
  bool _isLoading = false;

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
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final IProjectServices projectServices = GetIt.I.get<IProjectServices>();
    try {
      final String message = await projectServices.exportProject(
        projectId: widget.projectModel!.id!,
        fileName: _projectNameController.text,
        filePath: _projectPathController.text,
        format: _projectFormatController.text,
        password: _projectPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      dialogTitle: "Export Project",
      submitButtonText: _isLoading ? "Exporting..." : "Export",
      onSubmit: _onExportPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            controller: _projectNameController,
            labelText: 'File Name',
            enabled: !_isLoading,
          ),
          const SizedBox(height: 24),
          CustomTextFormField(
            controller: _projectPathController,
            labelText: 'Export Directory',
            suffixIcon: _isLoading
                ? null
                : PickFileOrFolderIcon(
                    onFilePicked: (filePath) {
                      if (filePath != null) {
                        _projectPathController.text = filePath;
                      }
                    },
                  ),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 10),
          ProjectFormatDropdownMenu(
            controller: _projectFormatController,
            enabled: !_isLoading,
          ),
          _projectFormatController.text == "ainoprj"
              ? Column(
                  children: [
                    const SizedBox(height: 24),
                    CustomTextFormField(
                      controller: _projectPasswordController,
                      labelText: 'Optional Password',
                      isRequired: false,
                      hintText: "No recovery (we don't have time)",
                      enabled: !_isLoading,
                      isPassword: true,
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class ProjectFormatDropdownMenu extends StatefulWidget {
  const ProjectFormatDropdownMenu({
    required this.controller,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  @override
  State<ProjectFormatDropdownMenu> createState() =>
      _ProjectFormatDropdownMenuState();
}

class _ProjectFormatDropdownMenuState extends State<ProjectFormatDropdownMenu> {
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
                onChanged: widget.enabled
                    ? (String? newValue) {
                        if (newValue == null) return;
                        setState(() => widget.controller.text = newValue);
                      }
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
