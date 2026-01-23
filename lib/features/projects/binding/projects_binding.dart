import 'package:get/get.dart';
import 'package:tree_expert/features/projects/presentation/controller/add_project_controller.dart';

class ProjectsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddProjectController(), fenix: true);
  }
}
