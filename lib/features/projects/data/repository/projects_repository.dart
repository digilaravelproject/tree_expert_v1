import '../../../../core/constent/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../model/project_list_model.dart';
import 'package:get/get.dart';

class ProjectsRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get project list
  Future<ApiResponse<List<ProjectListModel>>> getProjectList() async {
    try {
      final response = await _apiClient.get('/project/list');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> projectsJson = data['data'];
          final projects = projectsJson
              .map((json) => ProjectListModel.fromJson(json))
              .toList();

          return ApiResponse.success(
            projects,
            message: data['message'] ?? 'Projects fetched successfully',
            code: response.statusCode,
          );
        } else {
          return ApiResponse.error(
            data['message'] ?? 'Failed to fetch projects',
            code: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          'Failed to fetch projects',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error fetching projects: $e',
        error: e,
      );
    }
  }
}
