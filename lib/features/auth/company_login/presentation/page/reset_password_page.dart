import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/widgets/custom_image_view.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/styles/app_decoration.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../controller/company_login_controller.dart';

class ResetPasswordPage extends GetWidget<CompanyLoginController> {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryColorLight,
      extendBody: true,
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: CustomImageView(
                  url: "https://img.freepik.com/premium-photo/tree-field-against-sky-sunset_1048944-27499549.jpg",
                ),
              ),
              SizedBox(height: Get.height * 0.50),
            ],
          ),
          Form(
            key: controller.resetPasswordFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  decoration: AppDecorations.bottomSheetDecoration(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Icon
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.theme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_reset,
                              size: 52,
                              color: context.theme.primaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Welcome Text
                        Text(
                          "Reset Password 🔑",
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create a new strong password for your account.",
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// New Password Input
                        Obx(
                              () => AppInputTextField(
                            label: "New Password",
                            isObscure: controller.isShowNewPassword.value,
                            validator: FormValidator.password,
                            iconData: CupertinoIcons.lock_fill,
                            controller: controller.newPasswordController,
                            endIcon: controller.isShowNewPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            onEndIconTap: () {
                              controller.isShowNewPassword.toggle();
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// Confirm Password Input
                        Obx(
                              () => AppInputTextField(
                            label: "Confirm Password",
                            isObscure: controller.isShowConfirmPassword.value,
                            validator: (value) =>
                                FormValidator.confirmPassword(
                                  value,
                                  controller.newPasswordController.text,
                                ),
                            iconData: CupertinoIcons.lock,
                            controller: controller.confirmPasswordController,
                            endIcon: controller.isShowConfirmPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            onEndIconTap: () {
                              controller.isShowConfirmPassword.toggle();
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        Obx(
                              () => CustomButton(
                            title: "RESET PASSWORD",
                            onPressed: controller.resetPassword,
                            isLoading: controller.isLoading.value,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Back to login
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              "Back",
                              style: TextStyle(
                                color: context.theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Terms and Privacy
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text: "By continuing, you agree to our\n",
                                ),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: TextStyle(
                                    color: context.theme.primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      debugPrint("Privacy Policy clicked");
                                    },
                                ),
                                const TextSpan(text: " and "),
                                TextSpan(
                                  text: "Terms of Service",
                                  style: TextStyle(
                                    color: context.theme.primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      debugPrint("Terms of Service clicked");
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: context.mediaQueryPadding.bottom),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}