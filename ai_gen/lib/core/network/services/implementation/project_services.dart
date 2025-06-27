import 'package:ai_gen/core/models/project_model.dart';
import 'package:ai_gen/core/network/api_error_handler.dart';
import 'package:ai_gen/core/network/network_constants.dart';
import 'package:ai_gen/core/network/services/interfaces/project_services_interface.dart';
import 'package:ai_gen/core/services/cache_service.dart';
import 'package:dio/dio.dart';

class ProjectServices implements IProjectServices {
  final String _baseURL = NetworkConstants.baseURL;
  final String _projectEndPoint = NetworkConstants.projectEndPoint;
  final String _importProjectEndPoint = NetworkConstants.importProjectEndPoint;
  final String _exportProjectEndPoint = NetworkConstants.exportProjectEndPoint;
  final Dio _dio;

  ProjectServices(this._dio);

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final response = await _dio.get("$_baseURL/$_projectEndPoint/");

      if (response.data != null) {
        return List<ProjectModel>.from(
          response.data.map((project) => ProjectModel.fromJson(project)),
        );
      } else {
        throw Exception('Server error: No project data received');
      }
    } on DioException catch (e) {
      throw ApiErrorHandler.dioHandler(e);
    } catch (e) {
      throw ApiErrorHandler.handleGeneral(e as Exception);
    }
  }

  @override
  Future<ProjectModel> createProject(
      String projectName, String projectDescription) async {
    try {
      final response = await _dio.post(
        "$_baseURL/$_projectEndPoint/",
        data: {
          "project_name": projectName,
          "project_description": projectDescription,
        },
      );

      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.dioHandler(e);
    } catch (e) {
      throw ApiErrorHandler.handleGeneral(e as Exception);
    }
  }

  @override
  Future<ProjectModel> getProject(int projectId) async {
    try {
      final response =
          await _dio.get("$_baseURL/$_projectEndPoint/$projectId/");
      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.dioHandler(e);
    } catch (e) {
      throw ApiErrorHandler.handleGeneral(e as Exception);
    }
  }

  @override
  Future<String> importProject({
    required String filePath,
    String? password,
    int? projectId,
    int? replace = 0,
    String? projectName,
    String? projectDescription,
  }) async {
    try {
      final response = await _dio.get(
        "$_baseURL/$_importProjectEndPoint/?project_id=${projectId ?? ""}&replace=$replace",
        data: {
          "path": filePath,
          "password": password ?? "",
          "project_name": projectName ?? "",
          "project_description": projectDescription ?? "",
        },
      );

      if (response.data["project_id"] != null) {
        await CacheService()
            .setValue(filePath, response.data["project_id"].toString());
      }

      return response.data["message"];
    } on DioException catch (e) {
      throw ApiErrorHandler.dioHandler(e);
    } catch (e) {
      throw ApiErrorHandler.handleGeneral(e as Exception);
    }
  }

  @override
  Future<String> exportProject({
    required int projectId,
    required String fileName,
    required String filePath,
    String? password,
    String format = "ainoprj",
  }) async {
    try {
      final response = await _dio.post(
        "$_baseURL/$_exportProjectEndPoint/?project_id=$projectId",
        data: {
          "folder_path": filePath,
          "file_name": fileName,
          "format": format,
          "password": password ?? ""
        },
      );

      return response.data["message"];
    } on DioException catch (e) {
      throw ApiErrorHandler.dioHandler(e);
    } catch (e) {
      throw ApiErrorHandler.handleGeneral(e as Exception);
    }
  }
}
