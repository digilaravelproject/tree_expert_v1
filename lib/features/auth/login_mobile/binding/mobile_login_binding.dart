import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../presentation/controller/mobile_login_controller.dart';

class MobileLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MobileLoginController>(
      () => MobileLoginController(
        authService: Get.find<AuthService>(),
      ),
    );
  }
}