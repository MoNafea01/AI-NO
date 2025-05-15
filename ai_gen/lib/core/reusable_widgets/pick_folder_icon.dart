import 'package:ai_gen/core/utils/helper/helper.dart';
import 'package:flutter/material.dart';

enum PathType { file, folder }

class PickFileOrFolderIcon extends StatelessWidget {
  const PickFileOrFolderIcon({
    this.onFilePicked,
    this.pathType = PathType.folder,
    this.allowedExtensions,
    super.key,
  });

  final Function(String? pickedPath)? onFilePicked;
  final PathType pathType;
  final List<String>? allowedExtensions;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await _pick();
      },
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey[300],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      icon: const Icon(Icons.folder_open, color: Colors.black),
    );
  }

  Future<void> _pick() async {
    String? selectedPath = pathType == PathType.folder
        ? await Helper.pickDirectory()
        : await Helper.pickFile(allowedExtensions: allowedExtensions);

    onFilePicked?.call(selectedPath);
  }
}
