// Path: features/auth/company_login/data/data_source/company_auth_remote_ds.dart

import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constent/api_constants.dart';
import '../model/company_login_req.dart';
import '../model/company_login_res.dart';
import '../model/forgot_pass_req.dart';
import '../model/reset_pass_req.dart';

abstract class CompanyAuthRemoteDataSource {
  Future<CompanyLoginResponse> login(CompanyLoginRequest request);
  Future<Map<String, dynamic>> sendPasswordResetOtp(ForgotPasswordRequest request);
  Future<Map<String, dynamic>> verifyPasswordResetOtp(String email, String otp);
  Future<Map<String, dynamic>> resetPassword(ResetPasswordRequest request);
}

class CompanyAuthRemoteDataSourceImpl implements CompanyAuthRemoteDataSource {
  final ApiClient apiClient;

  CompanyAuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CompanyLoginResponse> login(CompanyLoginRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await apiClient.post(
        ApiConstants.loginEmailWithPassward,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CompanyLoginResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> sendPasswordResetOtp(
      ForgotPasswordRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await apiClient.post(
        ApiConstants.sendOtp,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP sent successfully',
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPasswordResetOtp(
      String email, String otp) async {
    try {
      final formData = FormData.fromMap({
        'email': email,
        'otp': otp,
      });

      final response = await apiClient.post(
        ApiConstants.verifyOtp,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP verified successfully',
        };
      } else {
        throw Exception(response.data['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword(
      ResetPasswordRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await apiClient.post(
        ApiConstants.resetPassword,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password reset successfully',
        };
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
}