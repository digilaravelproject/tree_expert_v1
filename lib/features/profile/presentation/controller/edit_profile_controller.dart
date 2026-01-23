import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../data/repository/profile_repository.dart';
import '../controller/profile_controller.dart';

class EditProfileController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ProfileController _profileController = Get.find<ProfileController>();

  // Form Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final designationController = TextEditingController();

  // Observable
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxString profileImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    if (_profileController.userProfile.value != null) {
      final profile = _profileController.userProfile.value!;
      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone.toString();
      designationController.text = profile.designation ?? '';
      profileImageUrl.value = profile.profileImage ?? '';
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Name is required");
      return;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar("Error", "Email is required");
      return;
    }

    isLoading.value = true;

    try {
      // Upload image if selected
      if (selectedImage.value != null) {
        int? userId = SharedPrefs.getInt(AppConstants.userIdPref);
        if (userId != null) {
          final response = await _profileRepository.uploadProfileImage(
            selectedImage.value!,
            userId,
          );

          if (!response.success) {
            Get.snackbar("Error", response.message ?? "Failed to upload image");
            isLoading.value = false;
            return;
          }
        }
      }

      // Refresh profile data
      await _profileController.fetchUserProfile();

      Get.snackbar(
        "Success",
        "Profile updated successfully!",
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    designationController.dispose();
    super.onClose();
  }
}
