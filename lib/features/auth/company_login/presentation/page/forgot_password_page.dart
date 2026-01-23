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

class ForgotPasswordPage extends GetWidget<CompanyLoginController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.theme.primaryColorLight,
      body: Stack(
        children: [
          /// 🔹 Background Image
          Positioned.fill(
            child: CustomImageView(
              url:
              "https://img.freepik.com/premium-photo/tree-field-against-sky-sunset_1048944-27499549.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Dark Overlay (Optional but professional look)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),

          /// 🔹 Bottom Sheet Content
          Form(
            key: controller.forgotPasswordFormKey,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: AppDecorations.bottomSheetDecoration(context),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Handle Bar
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

                      /// Icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.theme.primaryColor
                                .withValues(alpha: 0.1),
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

                      /// Title
                      Text(
                        "Forgot Password? 🔐",
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// Subtitle
                      Text(
                        "Enter your registered email address. We'll send you an OTP to reset your password.",
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Email Input
                      AppInputTextField(
                        label: "Email Address",
                        textInputType: TextInputType.emailAddress,
                        validator: FormValidator.email,
                        controller: controller.forgotEmailController,
                        iconData: CupertinoIcons.mail,
                      ),

                      const SizedBox(height: 32),

                      /// Send OTP Button
                      Obx(
                            () => CustomButton(
                          title: "SEND OTP",
                          isLoading: controller.isLoading.value,
                          onPressed:
                          controller.sendForgotPasswordOtp,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Back Button
                      Center(
                        child: TextButton(
                          onPressed: Get.back,
                          child: Text(
                            "Back to Company Login",
                            style: TextStyle(
                              color: context.theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Terms & Privacy
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

                      SizedBox(
                        height: context.mediaQueryPadding.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
