import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart' hide FormData;
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';

import '../../../core/constent/api_constants.dart';
import '../../../core/constent/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/shared_prefs.dart';
import '../../../core/storage/token_manger.dart';

class AuthService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Observable for login state
  final isLoggedIn = false.obs;
  final isCompanyLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    isLoggedIn.value = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;
    isCompanyLogin.value = SharedPrefs.getBool(AppConstants.isCompanyLoginPref) ?? false;
  }

  // ==================== USER AUTH ====================

  /// Send OTP to user's mobile
  Future<ApiResponse<Map<String, dynamic>>> sendOtpToMobile({
    required String phoneCode,
    required String mobile,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sendLoginOtp,
        data: FormData.fromMap({
          'phone': mobile,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          response.data,
          message: response.data['message'] ?? 'OTP sent successfully',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to send OTP',
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

  /// Verify OTP and login
  Future<ApiResponse<Map<String, dynamic>>> verifyOtpAndLogin({
    required String phoneCode,
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.otpVerify,
        data: FormData.fromMap({
          'phone': mobile,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Check verification status
        // 0 = Not verified (New) -> Register
        // 1 = Verified (Existing) -> Dashboard
        int isVerified = data['is_verified'] ?? 0;
        if (data['user'] != null && data['user']['is_verified'] != null) {
             isVerified = int.tryParse(data['user']['is_verified'].toString()) ?? 0;
        }


        // Also check is_new_user flag as fallback or combined logic if needed
        bool isNewUser = (isVerified == 0);

        // Save token if present (Always save)
        if (data['access_token'] != null) {
          await TokenManager.saveToken(data['access_token']);
        }

        if (data['user'] != null) {
          await SharedPrefs.setString(
            AppConstants.userDataPref,
            jsonEncode(data['user']),
          );
          if (data['user']['id'] != null) {
            await SharedPrefs.setInt(AppConstants.userIdPref, int.tryParse(data['user']['id'].toString()) ?? 0);
          }
        }

        if (!isNewUser) {
          // Save user data


          // Check role_id
          int roleId = data['user']['role_id'] ?? 0;
          bool isCompany = (roleId == AppConstants.roleIdCompany);

          // Update login state
          await SharedPrefs.setBool(AppConstants.isLoggedInPref, true);
          await SharedPrefs.setBool(AppConstants.isCompanyLoginPref, isCompany);
          isLoggedIn.value = true;
          isCompanyLogin.value = isCompany;
        }

        return ApiResponse.success(
          {
            'is_new_user': isNewUser,
            'user': data['user'],
          },
          message: data['message'] ?? 'Login successful',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Invalid OTP',
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

  /// Register new user
  /// Complete User Profile (Upload Profile Image & Details)
  Future<ApiResponse<Map<String, dynamic>>> completeUserProfile({
    required String userId,
    required String name,
    required String email,
    required String gender,
    required String aadhaarNumber,
    required String address,
    File? profileImage,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'user_id': userId,
        'name': name,
        'email': email,
        'gender': gender,
        'aadhaar_number': aadhaarNumber,
        'address': address,
      };

      // Add profile image if selected
      if (profileImage != null) {
        data['profile_image'] = await dio.MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        );
      }

      final response = await _apiClient.post(
        ApiConstants.uploadProfileImage,
        data: dio.FormData.fromMap(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Save updated user data
        if (data['data'] != null) {
          await SharedPrefs.setString(
            AppConstants.userDataPref,
            jsonEncode(data['data']),
          );
          if (data['data']['id'] != null) {
            await SharedPrefs.setInt(AppConstants.userIdPref, int.tryParse(data['data']['id'].toString()) ?? 0);
          }


          // Update login state & role
          int roleId = data['data']['role_id'] ?? 0;
          bool isCompany = (roleId == AppConstants.roleIdCompany);

          await SharedPrefs.setBool(AppConstants.isLoggedInPref, true);
          await SharedPrefs.setBool(AppConstants.isCompanyLoginPref, isCompany);
          isLoggedIn.value = true;
          isCompanyLogin.value = isCompany;
        }

        return ApiResponse.success(
          data,
          message: data['message'] ?? 'Profile updated successfully',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to update profile',
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

  // ==================== COMPANY AUTH ====================

  /// Company login with email and password
  Future<ApiResponse<Map<String, dynamic>>> companyLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.loginEmailWithPassward,
        data: FormData.fromMap({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Save token
        if (data['access_token'] != null) {
          await TokenManager.saveToken(data['access_token']);
        }

        // Save user data
        if (data['user'] != null) {
          await SharedPrefs.setString(
            AppConstants.userDataPref,
            jsonEncode(data['user']),
          );
          if (data['user']['id'] != null) {
            await SharedPrefs.setInt(AppConstants.userIdPref, int.tryParse(data['user']['id'].toString()) ?? 0);
          }
        }

        // Check role_id
        int roleId = data['user']['role_id'] ?? 0;
        bool isCompany = (roleId == AppConstants.roleIdCompany);

        // Update login state
        await SharedPrefs.setBool(AppConstants.isLoggedInPref, true);
        await SharedPrefs.setBool(AppConstants.isCompanyLoginPref, isCompany);
        isLoggedIn.value = true;
        isCompanyLogin.value = isCompany;

        return ApiResponse.success(
          {'user': data['user']},
          message: data['message'] ?? 'Login successful',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Login failed',
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

  // ==================== PASSWORD RESET ====================

  /// Send OTP for password reset
  Future<ApiResponse<Map<String, dynamic>>> sendPasswordResetOtp({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.sendOtp,
        data: {'email': email},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          {},
          message: response.data['message'] ?? 'OTP sent to your email',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to send OTP',
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

  /// Verify password reset OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          {'reset_token': response.data['reset_token']},
          message: response.data['message'] ?? 'OTP verified successfully',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Invalid OTP',
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

  /// Reset password
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          {},
          message: response.data['message'] ?? 'Password reset successfully',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to reset password',
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

  // ==================== COMMON ====================

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      // Ignore logout API errors
    } finally {
      // Clear all data
      await TokenManager.clearToken();
      await SharedPrefs.remove(AppConstants.userDataPref);
      await SharedPrefs.setBool(AppConstants.isLoggedInPref, false);
      await SharedPrefs.setBool(AppConstants.isCompanyLoginPref, false);

      isLoggedIn.value = false;
      isCompanyLogin.value = false;

      // Navigate to login
      Get.offAllNamed('/login_mobile');
    }
  }

  /// Get user profile
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile(int userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.userProfile}/$userId',
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          {'user': response.data['user']},
          message: 'Profile fetched successfully',
          code: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.data['message'] ?? 'Failed to get profile',
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
