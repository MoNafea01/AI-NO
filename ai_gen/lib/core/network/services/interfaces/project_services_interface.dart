import 'package:ai_gen/core/models/project_model.dart';

abstract class IProjectServices {
  Future<ProjectModel> createProject(
      String projectName, String projectDescription);
  Future<ProjectModel> getProject(int projectId);

  Future<String> importProject({
    required String filePath,
    String? password,
    int? projectId,
    int? replace = 0,
    String? projectName,
    String? projectDescription,
  });

  Future<String> exportProject({
    required int projectId,
    required String fileName,
    required String filePath,
    String? password,
    String format = "ainoprj",
  });

  Future<List<ProjectModel>> getAllProjects();
}
