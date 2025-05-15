import 'package:ai_gen/core/utils/helper/helper.dart';
import 'package:flutter/material.dart';

class PickfileTextField extends StatefulWidget {
  const PickfileTextField({
    required this.controller,
    this.allowedExtensions,
    this.onFilePicked,
    this.label,
    super.key,
  });

  final TextEditingController controller;
  final List<String>? allowedExtensions;
  final VoidCallback? onFilePicked;
  final Widget? label;
  @override
  State<PickfileTextField> createState() => _PickfileTextFieldState();
}

class _PickfileTextFieldState extends State<PickfileTextField> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: TextField(
        controller: widget.controller,
        onTap: () async {
          if (widget.controller.text.isNotEmpty) {
            return;
          }
          await _pickFile();
        },
        decoration: InputDecoration(
          label: widget.label,
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: _suffixIcon(),
        ),
        onChanged: (value) {
          setState(() => widget.onFilePicked?.call());
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
    String? file =
        await Helper.pickFile(allowedExtensions: widget.allowedExtensions);

    if (file != null) {
      widget.controller.text = file;
      widget.onFilePicked?.call();
    }
  }
}
