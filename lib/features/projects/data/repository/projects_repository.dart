import 'dart:convert';

import '../../../../core/constent/api_constants.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../model/project_list_model.dart';
import 'package:get/get.dart';

class ProjectsRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get project list
  /*Future<ApiResponse<List<ProjectListModel>>> getProjectList() async {
    try {
      final response = await _apiClient.get(ApiConstants.projectList);

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
  }*/



  Future<ApiResponse<List<ProjectListModel>>> getProjectList() async {
    try {
      // Get user_id and role_id from SharedPrefs
      final int? userId = SharedPrefs.getInt(AppConstants.userIdPref);
      String roleId = "";
      String? userDataStr = SharedPrefs.getString(AppConstants.userDataPref);
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        roleId = userData['role_id']?.toString() ?? "";
      }

      final Map<String, dynamic> body = {
        'user_id': userId,
        'role_id': roleId,
      };

      final response = await _apiClient.post(
        ApiConstants.projectAssignOfficer,
        data: body,
      );

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


  /// Get states list
  Future<ApiResponse<List<StateModel>>> getStates() async {
    try {
      final response = await _apiClient.get(ApiConstants.getStates);

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Note: API returns 'status' instead of 'success' for this endpoint
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> statesJson = data['data'];
          final states = statesJson
              .map((json) => StateModel.fromJson(json))
              .toList();

          return ApiResponse.success(
            states,
            message: data['message'] ?? 'States fetched successfully',
            code: response.statusCode,
          );
        } else {
          return ApiResponse.error(
            data['message'] ?? 'Failed to fetch states',
            code: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          'Failed to fetch states',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error fetching states: $e',
        error: e,
      );
    }
  }
  /// Create Project
  Future<ApiResponse<Map<String, dynamic>>> createProject({
    required String projectName,
    required String clientName,
    required String companyName,
    required int stateId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.createProject,
        data: {
          'project_name': projectName,
          'client_name': clientName,
          'company_name': companyName,
          'state_id': stateId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
         final data = response.data;
         if (data['status'] == true) {
           return ApiResponse.success(
             data['data'],
             message: data['message'] ?? 'Project created successfully',
             code: response.statusCode,
           );
         } else {
           return ApiResponse.error(
             data['message'] ?? 'Failed to create project',
             code: response.statusCode,
           );
         }
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to create project',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error creating project: $e',
        error: e,
      );
    }
  }

  /// Update Project
  Future<ApiResponse<Map<String, dynamic>>> updateProject({
    required int projectId,
    required String projectName,
    required String clientName,
    required String companyName,
    required int stateId,
  }) async {
    try {
      final response = await _apiClient.put(
        "${ApiConstants.updateProject}/$projectId",
        data: {
          'project_name': projectName,
          'client_name': clientName,
          'company_name': companyName,
          'state_id': stateId,
        },
      );

      if (response.statusCode == 200) {
         final data = response.data;
         if (data['status'] == true) {
           return ApiResponse.success(
             data['data'],
             message: data['message'] ?? 'Project updated successfully',
             code: response.statusCode,
           );
         } else {
           return ApiResponse.error(
             data['message'] ?? 'Failed to update project',
             code: response.statusCode,
           );
         }
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to update project',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error updating project: $e',
        error: e,
      );
    }
  }

  /// Get Project Export Links
  Future<ApiResponse<Map<String, dynamic>>> getProjectExportLinks(String projectId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getProjectExportLinks,
        data: {'project_id': projectId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return ApiResponse.success(
            data,
            message: data['message'] ?? 'Export links fetched successfully',
            code: response.statusCode,
          );
        } else {
          return ApiResponse.error(
            data['message'] ?? 'Failed to fetch export links',
            code: response.statusCode,
          );
        }
      } else {
        return ApiResponse.error(
          'Failed to fetch export links',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error fetching export links: $e',
        error: e,
      );
    }
  }
}
