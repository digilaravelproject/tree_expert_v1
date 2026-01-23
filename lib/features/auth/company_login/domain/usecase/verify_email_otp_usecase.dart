import '../repository/company_auth_repository.dart';

class VerifyEmailOtpUseCase {
  final CompanyAuthRepository repository;

  VerifyEmailOtpUseCase({required this.repository});

  Future<Map<String, dynamic>> call(String email, String otp) async {
    return await repository.verifyPasswordResetOtp(email, otp);
  }
}
