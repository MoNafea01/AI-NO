import 'package:ai_gen/core/models/node_model/parameter_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ParamSelectPath extends StatefulWidget {
  const ParamSelectPath({required this.parameter, super.key});

  final ParameterModel parameter;
  @override
  State<ParamSelectPath> createState() => _ParamSelectPathState();
}

class _ParamSelectPathState extends State<ParamSelectPath> {
  late final TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.parameter.value.toString());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ParamSelectPath oldWidget) {
    controller.text = widget.parameter.value.toString();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: TextField(
        controller: controller,
        // enabled: false,
        onTap: () async {
          if (controller.text.isNotEmpty) {
            return;
          }
          await _pickFile();
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: _suffixIcon(),
        ),
        onChanged: (value) {
          setState(() => widget.parameter.value = value);
        },
      ),
    );
  }

  Widget _suffixIcon() {
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
      allowedExtensions: widget.parameter.allowedExtensions!.cast<String>(),
      type: FileType.custom,
      lockParentWindow: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      controller.text = file.path ?? '';
    }
  }
}
