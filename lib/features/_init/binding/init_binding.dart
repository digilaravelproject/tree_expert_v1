import 'package:get/get.dart';
import '../presentation/controller/init_controller.dart';
import '../presentation/controller/intro_controller.dart';

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InitController());
    Get.lazyPut(() => IntroController());
  }
}