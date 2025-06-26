// ignore_for_file: avoid_print

import 'dart:io';

import '../../models/project_model.dart';

Future<ProjectModel?> checkArgs(List<String> args) async {
  print("Command line args: $args");

  // Access dart-define value (for development)
  const String filePath = String.fromEnvironment('file_path');

  String? initialProjectPath;

  if (filePath.isNotEmpty) {
    print("Opened with file (dart-define): $filePath");
    initialProjectPath = filePath;
  } else if (args.isNotEmpty) {
    final String pathToAinoFile = args[0];
    print("Opened with file (args): $pathToAinoFile");

    // Verify it's a .ainoprj file
    if (pathToAinoFile.toLowerCase().endsWith('.ainoprj')) {
      // Verify file exists
      final file = File(pathToAinoFile);
      if (await file.exists()) {
        initialProjectPath = pathToAinoFile;
        print("Valid .ainoprj file found: $pathToAinoFile");
      } else {
        print("File does not exist: $pathToAinoFile");
      }
    } else {
      print("Invalid file type. Expected .ainoprj file.");
    }
  } else {
    print("No file passed, open normal welcome screen");
  }

  final projectName =
      initialProjectPath?.split(Platform.pathSeparator).last.split('.').first;

  /// to check if the file has id and in database or not
  final int? projectID = null;

  ProjectModel projectModel = ProjectModel(
    name: projectName,
    path: initialProjectPath,
    id: projectID,
  );

  return projectModel;
}
