import '../../data/model/register_req.dart';
import '../../data/model/register_res.dart';

abstract class RegisterRepository {
  Future<RegisterResponse> registerUser(RegisterRequest request);
}
