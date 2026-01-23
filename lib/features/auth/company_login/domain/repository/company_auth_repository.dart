import '../../data/model/company_login_req.dart';
import '../../data/model/company_login_res.dart';
import '../../data/model/forgot_pass_req.dart';
import '../../data/model/reset_pass_req.dart';

abstract class CompanyAuthRepository {
  Future<CompanyLoginResponse> login(CompanyLoginRequest request);
  Future<Map<String, dynamic>> sendPasswordResetOtp(ForgotPasswordRequest request);
  Future<Map<String, dynamic>> verifyPasswordResetOtp(String email, String otp);
  Future<Map<String, dynamic>> resetPassword(ResetPasswordRequest request);
}
