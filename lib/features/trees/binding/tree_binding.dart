import 'package:get/get.dart';
import '../data/repository/trees_repository.dart';
import '../presentation/controller/add_tree_controller.dart';
import '../presentation/controller/tree_list_controller.dart';

class TreeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TreesRepository>(() => TreesRepository());
    Get.lazyPut<AddTreeController>(() => AddTreeController());
    Get.lazyPut<TreeListController>(() => TreeListController());
  }
}
