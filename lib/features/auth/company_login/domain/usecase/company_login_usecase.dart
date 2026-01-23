import '../../data/model/company_login_req.dart';
import '../../data/model/company_login_res.dart';
import '../repository/company_auth_repository.dart';

class CompanyLoginUseCase {
  final CompanyAuthRepository repository;

  CompanyLoginUseCase({required this.repository});

  Future<CompanyLoginResponse> call(CompanyLoginRequest request) async {
    return await repository.login(request);
  }
}
