import '../../domain/repository/company_auth_repository.dart';
import '../data_source/company_auth_remote_ds.dart';
import '../model/company_login_req.dart';
import '../model/company_login_res.dart';
import '../model/forgot_pass_req.dart';
import '../model/reset_pass_req.dart';

class CompanyAuthRepositoryImpl implements CompanyAuthRepository {
  final CompanyAuthRemoteDataSource remoteDataSource;

  CompanyAuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CompanyLoginResponse> login(CompanyLoginRequest request) async {
    try {
      return await remoteDataSource.login(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> sendPasswordResetOtp(
      ForgotPasswordRequest request) async {
    try {
      return await remoteDataSource.sendPasswordResetOtp(request);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPasswordResetOtp(
      String email, String otp) async {
    try {
      return await remoteDataSource.verifyPasswordResetOtp(email, otp);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword(
      ResetPasswordRequest request) async {
    try {
      return await remoteDataSource.resetPassword(request);
    } catch (e) {
      rethrow;
    }
  }
}