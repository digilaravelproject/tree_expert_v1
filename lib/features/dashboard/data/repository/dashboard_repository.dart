import 'dart:convert';

import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../model/dashboard_stats_model.dart';

class DashboardRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

/*
  Future<ApiResponse<DashboardStatsModel>> getDashboardStats() async {
    try {
      final response = await _apiClient.post(ApiConstants.dashboard);

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ApiResponse.success(
          DashboardStatsModel.fromJson(response.data['data']),
          message: response.data['message'] ?? 'Dashboard stats fetched successfully',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to fetch dashboard stats',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        e.toString(),
        error: e,
      );
    }
  }
*/


  Future<ApiResponse<DashboardStatsModel>> getDashboardStats() async {
    try {
      // SharedPreferences se user_id aur role_id le lo
      final int? userId = SharedPrefs.getInt(AppConstants.userIdPref);
      String roleId = "";
      String? userDataStr = SharedPrefs.getString(AppConstants.userDataPref);
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        roleId = userData['role_id']?.toString() ?? "";
      }

      if (userId == null || roleId == null) {
        return ApiResponse.error(
          'User ID or Role ID not found in SharedPreferences',
        );
      }

      // Post request data
      final Map<String, dynamic> requestData = {
        'user_id': userId,
        'role_id': roleId,
      };

      // API call
      final response = await _apiClient.post(
        ApiConstants.dashboard,
        data: requestData, // POST body me send karna hai
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return ApiResponse.success(
          DashboardStatsModel.fromJson(response.data['data']),
          message: response.data['message'] ?? 'Dashboard stats fetched successfully',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to fetch dashboard stats',
          code: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        e.toString(),
        error: e,
      );
    }
  }


}
