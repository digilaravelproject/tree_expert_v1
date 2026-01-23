import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constent/api_constants.dart';
import '../model/register_req.dart';
import '../model/register_res.dart';

abstract class RegisterRemoteDataSource {
  Future<RegisterResponse> registerUser(RegisterRequest request);
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  final ApiClient apiClient;

  RegisterRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<RegisterResponse> registerUser(RegisterRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await apiClient.post(
        ApiConstants.userRegister,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
}