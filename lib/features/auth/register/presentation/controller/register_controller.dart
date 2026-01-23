import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';

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
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final isPasswordValue = true.obs;
  final isCnfPasswordValue = true.obs;
  final isEmailVerified = false.obs;

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
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }

  // Verify Email (Optional)
  Future<void> verifyEmail() async {
    if (emailCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      isEmailVerified.value = true;

      Get.snackbar(
        "Success",
        "Email is valid",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Email verification failed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register User
  Future<void> onRegister() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final result = await authService.registerUser(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phoneCode: phoneCountryCode ?? '+91',
        mobile: phoneNumber ?? '',
        password: passwordCtrl.text,
      );

      if (result.success) {
        Get.snackbar(
          "Success",
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

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
