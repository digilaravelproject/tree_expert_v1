import '../../data/model/reset_pass_req.dart';
import '../repository/company_auth_repository.dart';

class ResetPasswordUseCase {
  final CompanyAuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<Map<String, dynamic>> call(ResetPasswordRequest request) async {
    return await repository.resetPassword(request);
  }
}