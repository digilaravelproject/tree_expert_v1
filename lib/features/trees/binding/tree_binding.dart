import 'package:get/get.dart';
import 'package:tree_expert/features/filter/presentation/controller/filter_controller.dart';
import 'package:tree_expert/features/trees/presentation/controller/add_tree_controller.dart';

import '../presentation/controller/tree_list_controller.dart';

class TreeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MatrimonyController());
    Get.lazyPut(() => FilterController(), fenix: true);
    Get.lazyPut(() => AddTreeController());
  }
}
