import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/constent/api_constants.dart';
import '../model/tree_model.dart';

class TreesRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<ApiResponse<List<TreeModel>>> getTrees() async {
    try {
      final response = await _apiClient.get(ApiConstants.treeList);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          final trees = data.map((json) => TreeModel.fromJson(json)).toList();
          return ApiResponse.success(trees);
        } else if (data is Map && data['status'] == true) {
          // Keep support for standard format just in case
          final List<dynamic> treesJson = data['data'] ?? [];
          final trees = treesJson
              .map((json) => TreeModel.fromJson(json))
              .toList();
          return ApiResponse.success(trees);
        } else {
          return ApiResponse.error(data is Map
              ? (data['message'] ?? 'Failed to load trees')
              : 'Unexpected response format');
        }
      } else {
        return ApiResponse.error('Failed to load trees');
      }
    }catch (e) {
      return ApiResponse.error('Error loading trees: $e');
    }

  }
  
  Future<ApiResponse<List<TreeModel>>> getTreesByProject(String projectId) async {
    try {
      final response = await _apiClient.get("${ApiConstants.treeInProject}/$projectId");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == true && data['data'] is List) {
          final List<dynamic> treesJson = data['data'];
          final trees = treesJson
              .map((json) => TreeModel.fromJson(json))
              .toList();
          return ApiResponse.success(trees);
        } else {
           // Handle direct list if API changes, but user response shows {status: true, data: [...]}
           return ApiResponse.error(data is Map 
            ? (data['message'] ?? 'Failed to load project trees') 
            : 'Unexpected response');
        }
      } else {
        return ApiResponse.error('Failed to load project trees');
      }
    } catch (e) {
      return ApiResponse.error('Error loading project trees: $e');
    }
  }

  /// Measure tree (calculate height, canopy, age from girth)
  Future<ApiResponse<Map<String, dynamic>>> measureTree({required double girth}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.treeMeasure,
        data: {'girth': girth},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Check if data is directly the map with keys
        if (data is Map<String, dynamic> && data.containsKey('girth_cm')) {
           return ApiResponse.success(data);
        } else if (data is Map && data.containsKey('data')) {
           // Handle wrapped response
           return ApiResponse.success(data['data']);
        } else {
           // Fallback or error
           return ApiResponse.success(data);
        }
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to measure tree');
      }

    } catch (e) {
      return ApiResponse.error('Error measuring tree: $e');
    }
  }

  /// Submit all trees
  Future<ApiResponse<Map<String, dynamic>>> submitTrees(List<Map<String, dynamic>> treesData) async {
    try {
      // Need to handle file uploads if phtos are local paths
      // For now assuming simple JSON post, but likely needs FormData if photos are involved.
      // Given the complexity of checking file paths vs URLs, I'll start with basic JSON 
      // and user can refine if MultipartNeeded.

      print("datatrees: $treesData");
      
      // Sending list directly as API validation suggests root level fields expectation (or list root)
      final response = await _apiClient.post(
        ApiConstants.saveTrees,
        data: treesData, 
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
         final data = response.data;
         if (data is Map && (data['status'] == true || data['success'] == true)) {
           return ApiResponse.success(data as Map<String, dynamic>);
         } else {
           return ApiResponse.error(data is Map ? (data['message'] ?? 'Failed to submit trees') : 'Failed');
         }
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to submit trees');
      }
    } catch (e) {
      return ApiResponse.error('Error submitting trees: $e');
    }
  }
}
