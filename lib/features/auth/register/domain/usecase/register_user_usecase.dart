import '../../data/model/register_req.dart';
import '../../data/model/register_res.dart';
import '../repository/register_repository.dart';

class RegisterUserUseCase {
  final RegisterRepository repository;

  RegisterUserUseCase({required this.repository});

  Future<RegisterResponse> call(RegisterRequest request) async {
    return await repository.registerUser(request);
  }
}