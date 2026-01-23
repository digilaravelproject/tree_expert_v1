import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../model/dashboard_stats_model.dart';

class DashboardRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<ApiResponse<DashboardStatsModel>> getDashboardStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.dashboard);

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
