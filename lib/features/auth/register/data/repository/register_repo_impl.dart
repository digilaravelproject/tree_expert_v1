import '../../domain/repository/register_repository.dart';
import '../data_source/register_remote_ds.dart';
import '../model/register_req.dart';
import '../model/register_res.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource remoteDataSource;

  RegisterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RegisterResponse> registerUser(RegisterRequest request) async {
    try {
      return await remoteDataSource.registerUser(request);
    } catch (e) {
      rethrow;
    }
  }
}
