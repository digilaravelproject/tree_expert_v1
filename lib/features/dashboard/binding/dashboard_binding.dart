import 'package:get/get.dart';

import '../presentation/controller/dashboard_controller.dart';
import '../presentation/controller/home_controller.dart';
import '../../projects/data/repository/projects_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ProjectsRepository(), fenix: true);
  }
}
