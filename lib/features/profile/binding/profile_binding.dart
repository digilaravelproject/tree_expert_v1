import 'package:tree_expert/features/profile/presentation/controller/edit_profile_controller.dart';
import 'package:tree_expert/features/profile/presentation/controller/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController());
    Get.lazyPut(() => ProfileController());
  }
}
