import 'package:get/get.dart';
import '../presentation/controller/geo_camera_controller.dart';

class GeoCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GeoCameraController>(
      () => GeoCameraController(),
    );
  }
}
