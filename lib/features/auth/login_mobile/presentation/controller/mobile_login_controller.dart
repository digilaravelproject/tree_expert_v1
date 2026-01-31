import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';

import 'package:tree_expert/core/constent/app_constants.dart';
import '../../../services/auth_service.dart';
import '../page/otp_verification_page.dart';

class MobileLoginController extends GetxController {
    final AuthService authService;

    MobileLoginController({required this.authService});

    // Form Keys
    final formKey = GlobalKey<FormState>();

    // Text Controllers
    final mobileController = TextEditingController();

    // Observables
    final isLoading = false.obs;
    final selectedPhone = Rx<PhoneCountry>(PhoneCountry.india);

    @override
    void onClose() {
        mobileController.dispose();
        super.onClose();
    }

    // Pick Country Code
    void pickCountry() {
        // TODO: Implement country picker
        Get.snackbar(
            "Country Picker",
            "Implement country picker dialog here",
            snackPosition: SnackPosition.BOTTOM,
        );
    }

    // Send OTP
    Future<void> sendOtp() async {
        if (!formKey.currentState!.validate()) return;

        try {
            isLoading.value = true;

            final result = await authService.sendOtpToMobile(
                phoneCode: selectedPhone.value.displayCC,
                mobile: mobileController.text.trim(),
            );

            if (result.success) {
                // Navigate to OTP verification
                VerifyOtpBottomSheet.show(this);

                Get.snackbar(
                    "Success",
                    result.message,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                );
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
                "Failed to send OTP: $e",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
            );
        } finally {
            isLoading.value = false;
        }
    }

    // Verify OTP
    Future<void> verifyOtp(String otp) async {
        if (otp.length != AppConstants.otpLength) {
            Get.snackbar(
                "Error",
                "Please enter complete ${AppConstants.otpLength}-digit OTP",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
            );
            return;
        }

        try {
            isLoading.value = true;

            final result = await authService.verifyOtpAndLogin(
                phoneCode: selectedPhone.value.displayCC,
                mobile: mobileController.text.trim(),
                otp: otp,
            );

            if (result.success && result.data != null) {
                // Check if user is new or existing
                bool isNewUser = result.data!['is_new_user'] ?? false;

                Get.snackbar(
                    "Success",
                    result.message,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                );

                if (isNewUser) {
                    // Navigate to Register Page with phone data
                    Get.toNamed(
                        AppRoutes.register,
                        arguments: {
                            'phone': mobileController.text.trim(),
                            'phoneCode': selectedPhone.value.displayCC,
                        },
                    );
                } else {
                    // Navigate to Dashboard
                    Get.offAllNamed(AppRoutes.dashboard);
                }
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
                "Invalid OTP: $e",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
            );
        } finally {
            isLoading.value = false;
        }
    }

    // Resend OTP
    Future<void> resendOtp() async {
        try {
            final result = await authService.sendOtpToMobile(
                phoneCode: selectedPhone.value.displayCC,
                mobile: mobileController.text.trim(),
            );

            if (result.success) {
                Get.snackbar(
                    "Success",
                    result.message,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                );
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
                "Failed to resend OTP: $e",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
            );
        }
    }
}

// Phone Country Model
class PhoneCountry {
    final String name;
    final String code;
    final String displayCC;
    final String flag;
    final int maxLength;

    PhoneCountry({
        required this.name,
        required this.code,
        required this.displayCC,
        required this.flag,
        required this.maxLength,
    });

    static PhoneCountry india = PhoneCountry(
        name: "India",
        code: "IN",
        displayCC: "+91",
        flag: "🇮🇳",
        maxLength: 10,
    );

    static PhoneCountry usa = PhoneCountry(
        name: "USA",
        code: "US",
        displayCC: "+1",
        flag: "🇺🇸",
        maxLength: 10,
    );
}