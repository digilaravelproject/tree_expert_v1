import '../../data/model/forgot_pass_req.dart';
import '../repository/company_auth_repository.dart';

class ForgotPasswordUseCase {
  final CompanyAuthRepository repository;

  ForgotPasswordUseCase({required this.repository});

  Future<Map<String, dynamic>> call(ForgotPasswordRequest request) async {
    return await repository.sendPasswordResetOtp(request);
  }
}
