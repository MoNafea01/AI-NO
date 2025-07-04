import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/data/network/services/interfaces/project_services_interface.dart';
import 'package:ai_gen/core/utils/reusable_widgets/custom_dialog.dart';
import 'package:ai_gen/core/utils/reusable_widgets/custom_text_form_field.dart';
import 'package:ai_gen/core/utils/reusable_widgets/pick_folder_icon.dart';
import 'package:ai_gen/core/utils/themes/app_colors.dart';
import 'package:ai_gen/features/node_view/cubit/grid_node_view_cubit.dart';
import 'package:ai_gen/features/screens/HomeScreen/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ImportProjectDialog extends StatefulWidget {
  const ImportProjectDialog({
    this.projectModel,
    this.cubit,
    this.outsourceProject = false,
    super.key,
  });

  final ProjectModel? projectModel;
  final Cubit? cubit;

  //  used when the project is opened from the main args
  final bool outsourceProject;

  @override
  State<ImportProjectDialog> createState() => _ImportProjectDialogState();
}

class _ImportProjectDialogState extends State<ImportProjectDialog> {
  late final TextEditingController _projectpathController;
  late final TextEditingController _projectNameController;
  late final TextEditingController _projectDescriptionController;
  late final TextEditingController _projectPasswordController;

  bool _isLoading = false;
  int isReplace = 0;

  @override
  void initState() {
    _projectpathController = TextEditingController(
        text: widget.outsourceProject ? widget.projectModel?.path : null);
    _projectPasswordController = TextEditingController();
    _projectNameController = TextEditingController(
        text: widget.outsourceProject ? widget.projectModel?.name : null);
    _projectDescriptionController = TextEditingController(
        text:
            widget.outsourceProject ? widget.projectModel?.description : null);
    super.initState();
  }

  @override
  void dispose() {
    _projectpathController.dispose();
    _projectPasswordController.dispose();
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }

  void _onImportPressed() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final IProjectServices projectServices = GetIt.I.get<IProjectServices>();

    try {
      final String message = await projectServices.importProject(
        filePath: _projectpathController.text,
        password: _projectPasswordController.text,
        projectId: widget.projectModel?.id,
        replace: isReplace,
        projectName: _projectNameController.text,
        projectDescription: _projectDescriptionController.text,
      );

      if (mounted) {
        if (widget.cubit is HomeCubit) {
          (widget.cubit as HomeCubit).loadHomePage();
        } else if (widget.cubit is GridNodeViewCubit) {
          (widget.cubit as GridNodeViewCubit).updateNodes();
        }
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
      dialogTitle: "Import Project",
      submitButtonText: "Import",
      onSubmit: _onImportPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          CustomTextFormField(
            controller: _projectpathController,
            labelText: 'Project File',
            suffixIcon: PickFileOrFolderIcon(
              pathType: PathType.file,
              allowedExtensions: const ["ainoprj", "Json"],
              onFilePicked: (filePath) {
                if (filePath != null) {
                  _projectpathController.text = filePath;
                }
              },
            ),
            enabled: !_isLoading,
          ),
          CustomTextFormField(
            labelText: "Password?",
            controller: _projectPasswordController,
            isPassword: true,
            isRequired: false,
            enabled: !_isLoading,
          ),
          CustomTextFormField(
            labelText: "Project Name",
            controller: _projectNameController,
            isRequired: false,
            enabled: !_isLoading,
          ),
          CustomTextFormField(
            labelText: "Description",
            controller: _projectDescriptionController,
            isRequired: false,
            enabled: !_isLoading,
          ),
          if (!widget.outsourceProject)
            ToggleSwitch(
              minWidth: 900,
              cornerRadius: 12.0,
              activeBgColors: const [
                [AppColors.bluePrimaryColor],
                [Colors.red]
              ],
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              initialLabelIndex: 0,
              labels: const ['Merge', 'Replace'],
              fontSize: 16,
              icons: const [
                FontAwesomeIcons.codePullRequest,
                FontAwesomeIcons.trash
              ],
              iconSize: 14,
              onToggle: (index) {
                isReplace = index ?? 0;
              },
            ),
        ],
      ),
    );
  }
}
