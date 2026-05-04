import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';

import 'package:tree_expert/core/constent/app_constants.dart';
import 'package:tree_expert/core/helper/country_list_picker.dart';
import '../../../services/auth_service.dart';
import '../page/otp_verification_page.dart';

class MobileLoginController extends GetxController {
    final AuthService authService;

    MobileLoginController({required this.authService}) {
        mobileController.addListener(() {
            _updateIdentifier();
        });
        emailController.addListener(() {
            _updateIdentifier();
        });
    }

    void _updateIdentifier() {
        final loginFormat = AppConstants.loginFormteEmailAndPassword;
        if (loginFormat == "email") {
            identifier.value = emailController.text.trim();
        } else {
            identifier.value = mobileController.text.trim();
        }
    }

    // Form Keys
    final formKey = GlobalKey<FormState>();

    // Text Controllers
    final mobileController = TextEditingController();
    final emailController = TextEditingController();

    // Observables
    final isLoading = false.obs;
    final selectedPhone = countries.firstWhere((c) => c.code == "IN").obs;
    final identifier = "".obs;

    @override
    void onClose() {
        mobileController.dispose();
        emailController.dispose();
        super.onClose();
    }

    // Pick Country Code
    void pickCountry() {
        Get.to(() => CountriesList(onTap: (country) {
            selectedPhone.value = country;
        }));
    }

    // Send OTP / Login
    Future<void> login() async {
        if (!formKey.currentState!.validate()) return;
        await sendOtp();
    }

    // Send OTP
    Future<void> sendOtp() async {
        try {
            isLoading.value = true;

            final loginFormat = AppConstants.loginFormteEmailAndPassword;
            
            String identifier = mobileController.text.trim();
            bool isEmail = false;

            if (loginFormat == "email") {
                isEmail = true;
                identifier = emailController.text.trim();
            } else if (loginFormat == "mobile") {
                isEmail = false;
                identifier = mobileController.text.trim();
            } else {
                // If empty or "dono", detect from input
                if (identifier.contains('@')) {
                    isEmail = true;
                } else {
                    isEmail = false;
                }
            }

            final result = await authService.sendOtpToMobile(
                phoneCode: selectedPhone.value.displayCC,
                email: isEmail ? identifier : null,
                mobile: isEmail ? null : identifier,
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

            final loginFormat = AppConstants.loginFormteEmailAndPassword;
            
            String identifier = mobileController.text.trim();
            bool isEmail = false;

            if (loginFormat == "email") {
                isEmail = true;
                identifier = emailController.text.trim();
            } else if (loginFormat == "mobile") {
                isEmail = false;
                identifier = mobileController.text.trim();
            } else {
                if (identifier.contains('@')) {
                    isEmail = true;
                } else {
                    isEmail = false;
                }
            }

            final result = await authService.verifyOtpAndLogin(
                phoneCode: selectedPhone.value.displayCC,
                email: isEmail ? identifier : null,
                mobile: isEmail ? null : identifier,
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
                    // Navigate to Register Page with login data
                    Get.toNamed(
                        AppRoutes.register,
                        arguments: {
                            'phone': isEmail ? null : identifier,
                            'email': isEmail ? identifier : null,
                            'phoneCode': selectedPhone.value.displayCC,
                            'loginType': isEmail ? 'email' : 'phone',
                            'user': result.data!['user'], // Pass user object
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
            final loginFormat = AppConstants.loginFormteEmailAndPassword;
            
            String identifier = mobileController.text.trim();
            bool isEmail = false;

            if (loginFormat == "email") {
                isEmail = true;
                identifier = emailController.text.trim();
            } else if (loginFormat == "mobile") {
                isEmail = false;
                identifier = mobileController.text.trim();
            } else {
                if (identifier.contains('@')) {
                    isEmail = true;
                } else {
                    isEmail = false;
                }
            }

            final result = await authService.sendOtpToMobile(
                phoneCode: selectedPhone.value.displayCC,
                email: isEmail ? identifier : null,
                mobile: isEmail ? null : identifier,
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