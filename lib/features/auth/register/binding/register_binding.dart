import 'package:get/get.dart';
import 'package:tree_expert/core/network/api_client.dart';

import '../../services/auth_service.dart';
import '../data/data_source/register_remote_ds.dart';
import '../data/repository/register_repo_impl.dart';
import '../domain/repository/register_repository.dart';
import '../domain/usecase/register_user_usecase.dart';
import '../presentation/controller/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<RegisterRemoteDataSource>(
          () => RegisterRemoteDataSourceImpl(
        apiClient: Get.find<ApiClient>(),
      ),
    );

    // Repository
    Get.lazyPut<RegisterRepository>(
          () => RegisterRepositoryImpl(
        remoteDataSource: Get.find<RegisterRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut(() => RegisterUserUseCase(
      repository: Get.find<RegisterRepository>(),
    ));

    // Controller
    Get.lazyPut<RegisterController>(
          () => RegisterController(
        authService: Get.find<AuthService>(),
        registerUserUseCase: Get.find<RegisterUserUseCase>(),
      ),
    );
  }
}