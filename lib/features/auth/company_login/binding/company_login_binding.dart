// Path: features/auth/company_login/binding/company_login_binding.dart

import 'package:get/get.dart';
import 'package:tree_expert/core/network/api_client.dart';

import '../../services/auth_service.dart';

import '../data/data_source/company_auth_remote_ds.dart';
import '../data/repository/company_auth_repo_impl.dart';
import '../domain/repository/company_auth_repository.dart';
import '../domain/usecase/company_login_usecase.dart';
import '../domain/usecase/forgot_password_usecase.dart';
import '../domain/usecase/verify_email_otp_usecase.dart';
import '../domain/usecase/reset_password_usecase.dart';
import '../presentation/controller/company_login_controller.dart';

class CompanyLoginBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<CompanyAuthRemoteDataSource>(
          () => CompanyAuthRemoteDataSourceImpl(
        apiClient: Get.find<ApiClient>(),
      ),
    );

    // Repository
    Get.lazyPut<CompanyAuthRepository>(
          () => CompanyAuthRepositoryImpl(
        remoteDataSource: Get.find<CompanyAuthRemoteDataSource>(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => CompanyLoginUseCase(
      repository: Get.find<CompanyAuthRepository>(),
    ));

    Get.lazyPut(() => ForgotPasswordUseCase(
      repository: Get.find<CompanyAuthRepository>(),
    ));

    Get.lazyPut(() => VerifyEmailOtpUseCase(
      repository: Get.find<CompanyAuthRepository>(),
    ));

    Get.lazyPut(() => ResetPasswordUseCase(
      repository: Get.find<CompanyAuthRepository>(),
    ));

    // Controller
    Get.lazyPut<CompanyLoginController>(
          () => CompanyLoginController(
        authService: Get.find<AuthService>(),
        loginUseCase: Get.find<CompanyLoginUseCase>(),
        forgotPasswordUseCase: Get.find<ForgotPasswordUseCase>(),
        verifyEmailOtpUseCase: Get.find<VerifyEmailOtpUseCase>(),
        resetPasswordUseCase: Get.find<ResetPasswordUseCase>(),
      ),
    );
  }
}