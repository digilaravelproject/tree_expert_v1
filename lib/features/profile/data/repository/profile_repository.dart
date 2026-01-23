import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../../../core/constent/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../model/user_profile_data.dart';
import '../model/contact_model.dart';
import '../model/note_model.dart';
import '../model/privacy_policy_model.dart';

class ProfileRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get User Profile
  Future<ApiResponse<UserProfileModel>> getUserProfile(int userId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.userProfile}/$userId');
      if (response.statusCode == 200) {
        return ApiResponse.success(
          UserProfileModel.fromJson(response.data),
          message: 'Profile fetched successfully',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Failed to get profile', code: response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error(e.toString(), error: e);
    }
  }

  /// Upload Profile Image
  Future<ApiResponse<Map<String, dynamic>>> uploadProfileImage(File image, int userId) async {
    try {
      String fileName = image.path.split('/').last;
      
      final formData = dio.FormData.fromMap({
        'profile_image': await dio.MultipartFile.fromFile(image.path, filename: fileName),
        'user_id': userId,
      });

      final response = await _apiClient.post(
        ApiConstants.uploadProfileImage,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data, message: 'Image uploaded successfully');
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Upload failed', code: response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error(e.toString(), error: e);
    }
  }

  /// Rate User
  Future<ApiResponse<Map<String, dynamic>>> rateUser(int userId, double rating, String comment) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.userRating,
        data: {
          'user_id': userId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(response.data, message: response.data['message']);
      } else {
        return ApiResponse.error(response.data['message'] ?? 'Rating failed', code: response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error(e.toString(), error: e);
    }
  }

  /// Get Contacts
  Future<ApiResponse<List<ContactModel>>> getContacts() async {
    try {
      final response = await _apiClient.get(ApiConstants.contacts);
      if (response.statusCode == 200 && response.data['success'] == true) {
        List<ContactModel> contacts = (response.data['data'] as List)
            .map((e) => ContactModel.fromJson(e))
            .toList();
        return ApiResponse.success(contacts, message: "Contacts fetched");
      } else {
        return ApiResponse.error("Failed to fetch contacts", code: response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error(e.toString(), error: e);
    }
  }

  /// Get Notes
  Future<ApiResponse<List<NoteModel>>> getNotes() async {
    try {
      final response = await _apiClient.get(ApiConstants.notes);
      if (response.statusCode == 200 && response.data['success'] == true) {
         List<NoteModel> notes = (response.data['data'] as List)
            .map((e) => NoteModel.fromJson(e))
            .toList();
        return ApiResponse.success(notes, message: "Notes fetched");
      } else {
        return ApiResponse.error("Failed to fetch notes", code: response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error(e.toString(), error: e);
    }
  }

  /// Get Privacy Policy
  Future<ApiResponse<PrivacyPolicyModel>> getPrivacyPolicy() async {
    try {
      final response = await _apiClient.get(ApiConstants.privacyPolicy);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ApiResponse.success(
          PrivacyPolicyModel.fromJson(response.data['policies'][0]),
          message: "Privacy Policy fetched"
        );
      } else {
        return ApiResponse.error("Failed to fetch policy", code: response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error(e.toString(), error: e);
    }
  }
}
