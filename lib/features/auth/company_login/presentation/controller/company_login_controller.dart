// Path: features/auth/company_login/presentation/controller/company_login_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';

import '../../../services/auth_service.dart';
import '../../domain/usecase/company_login_usecase.dart';
import '../../domain/usecase/forgot_password_usecase.dart';
import '../../domain/usecase/verify_email_otp_usecase.dart';
import '../../domain/usecase/reset_password_usecase.dart';
import '../page/email_otp_verification_page.dart';

class CompanyLoginController extends GetxController {
  // Auth Service
  final AuthService authService;
  
  // Use Cases (kept for compatibility)
  final CompanyLoginUseCase loginUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyEmailOtpUseCase verifyEmailOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  CompanyLoginController({
    required this.authService,
    required this.loginUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyEmailOtpUseCase,
    required this.resetPasswordUseCase,
  });

  // Form Keys
  final formKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // Text Controllers - Login
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Text Controllers - Forgot Password
  final forgotEmailController = TextEditingController();

  // Text Controllers - Reset Password
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final isShowPassword = true.obs;
  final isShowNewPassword = true.obs;
  final isShowConfirmPassword = true.obs;

  // Store OTP for verification
  String? sentOtp;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Company Login
  Future<void> performLogin() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final result = await authService.companyLogin(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.success) {
        Get.snackbar(
          "Success",
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to Company Dashboard
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

  // Send Forgot Password OTP
  Future<void> sendForgotPasswordOtp() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final result = await authService.sendPasswordResetOtp(
        email: forgotEmailController.text.trim(),
      );

      if (result.success) {
        Get.snackbar(
          "Success",
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to Email OTP Verification
        EmailOtpVerificationPage.show(this);
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

  // Resend Email OTP
  Future<void> resendEmailOtp() async {
    await sendForgotPasswordOtp();
  }

  // Verify Email OTP
  Future<void> verifyEmailOtp(String otp) async {
    if (otp.length != 6) {
      Get.snackbar(
        "Error",
        "Please enter complete 6-digit OTP",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final result = await authService.verifyPasswordResetOtp(
        email: forgotEmailController.text.trim(),
        otp: otp,
      );

      if (result.success) {
        // Store OTP for reset password
        sentOtp = otp;

        Get.snackbar(
          "Success",
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to Reset Password Page
        Get.offAndToNamed(AppRoutes.resetPassword);
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

  // Reset Password
  Future<void> resetPassword() async {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final result = await authService.resetPassword(
        email: forgotEmailController.text.trim(),
        otp: sentOtp ?? '',
        newPassword: newPasswordController.text,
      );

      if (result.success) {
        Get.snackbar(
          "Success",
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear controllers
        newPasswordController.clear();
        confirmPasswordController.clear();
        forgotEmailController.clear();
        sentOtp = null;

        // Navigate back to Company Login
        Get.offAllNamed(AppRoutes.companyLogin);
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