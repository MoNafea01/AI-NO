import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ProjectRepository {
  final String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> deleteProjects(List<int> projectIds) async {
    try {
      log('Attempting to delete projects: $projectIds');
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

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete projects: ${response.statusCode}');
      }
    } catch (e) {
      log('Error deleting projects: $e');
      throw Exception('Network error or server issue: $e');
    }
  }

  Future<bool> deleteEmptyProjects() async {
    try {
      log('Attempting to delete empty projects');
      final response = await http.delete(
        Uri.parse('$_baseUrl/projects/delete-empty-projects/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Failed to delete empty projects: ${response.statusCode}');
      }
    } catch (e) {
      log('Error deleting empty projects: $e');
      throw Exception('Network error or server issue: $e');
    }
  }

  
}
