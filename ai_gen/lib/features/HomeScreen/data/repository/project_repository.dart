import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectRepository {
  final String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> deleteProjects(List<int> projectIds) async {
    try {
      print('Attempting to delete projects: $projectIds');
      final response = await http.delete(
        Uri.parse('$_baseUrl/projects/bulk-delete/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'projects_ids': projectIds,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting projects: $e');
      throw Exception('Network error or server issue: $e');
    }
  }

  Future<bool> deleteEmptyProjects() async {
    try {
      print('Attempting to delete empty projects');
      final response = await http.delete(
        Uri.parse('$_baseUrl/projects/delete-empty-projects/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Failed to delete empty projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting empty projects: $e');
      throw Exception('Network error or server issue: $e');
    }
  }

  // You would also add methods here to fetch projects, e.g.,
  // Future<List<ProjectModel>> fetchProjects() async {
  //   final response = await http.get(Uri.parse('$_baseUrl/projects/'));
  //   if (response.statusCode == 200) {
  //     List<dynamic> body = json.decode(response.body);
  //     return body.map((dynamic item) => ProjectModel.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Failed to load projects');
  //   }
  // }
}
