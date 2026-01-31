import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tree_expert/core/routes/app_routes.dart';
import 'package:tree_expert/core/storage/shared_prefs.dart';
import 'package:tree_expert/core/constent/app_constants.dart';
import 'dart:convert';

import '../../../services/auth_service.dart';
import '../../data/model/register_req.dart';
import '../../domain/usecase/register_user_usecase.dart';

class RegisterController extends GetxController {
  // Auth Service
  final AuthService authService;

  // Use Case (kept for compatibility)
  final RegisterUserUseCase registerUserUseCase;

  RegisterController({
    required this.authService,
    required this.registerUserUseCase,
  });

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final isEmailVerified = false.obs;
  final selectedGender = 'Male'.obs;
  final profileImage = Rx<File?>(null);

  // Get phone from previous screen
  String? phoneNumber;
  String? phoneCountryCode;

  @override
  void onInit() {
    super.onInit();
    // Get data from arguments if passed
    final args = Get.arguments;
    if (args != null) {
      phoneNumber = args['phone'];
      phoneCountryCode = args['phoneCode'];
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    aadhaarCtrl.dispose();
    super.onClose();
  }

  // Pick Image
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  // Register User / Complete Profile
  Future<void> onRegister() async {
    if (!formKey.currentState!.validate()) return;

    if (aadhaarCtrl.text.length != 12) {
      Get.snackbar("Error", "Aadhaar number must be 12 digits",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // Get User ID from Shared Prefs
      String? userDataStr = SharedPrefs.getString(AppConstants.userDataPref);
      if (userDataStr == null) {
        Get.snackbar("Error", "User details not found. Please login again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
      
      Map<String, dynamic> userData = jsonDecode(userDataStr);
      String userId = userData['id'].toString();

      final result = await authService.completeUserProfile(
        userId: userId,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        gender: selectedGender.value.toLowerCase(),
        aadhaarNumber: aadhaarCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        profileImage: profileImage.value,
      );

      if (result.success) {
        Get.snackbar(
          "Success",
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Update local user data with new details if needed
        // Assuming the API returns updated user object, we can update SharedPrefs
        if (result.data != null && result.data is Map<String, dynamic> && result.data!.containsKey('user')) {
             await SharedPrefs.setString(
              AppConstants.userDataPref,
              jsonEncode(result.data!['user']),
            );
        }

        // Navigate to Dashboard
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.snackbar(
          "Error",
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
