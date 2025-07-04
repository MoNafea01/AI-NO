// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:ai_gen/core/data/cache/cache_services/cache_service.dart';

import '../../models/project_model.dart';

///to pass arguments to test it
/// flutter run -d windows --dart-define=file_path="C:\Users\mahmo\Desktop\ELDemy.ainoprj"
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

  final String? projectName =
      initialProjectPath?.split(Platform.pathSeparator).last.split('.').first;

  /// to check if the file has id and in database or not
  final String? storedProjectID =
      await CacheService().getValue(initialProjectPath ?? '');

  log("Open Stored project ID: $storedProjectID");
  final int? projectID = int.tryParse(storedProjectID ?? '');

  return initialProjectPath == null
      ? null
      : ProjectModel(
          name: projectName,
          path: initialProjectPath,
          id: projectID,
        );
}
