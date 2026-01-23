import 'package:tree_expert/features/search/presentation/controller/search_controller.dart';
import 'package:get/get.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DateSearchController());
  }
}
