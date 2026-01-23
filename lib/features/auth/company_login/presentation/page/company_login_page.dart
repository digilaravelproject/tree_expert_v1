import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/widgets/custom_image_view.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/styles/app_decoration.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../controller/company_login_controller.dart';

class CompanyLoginPage extends GetWidget<CompanyLoginController> {
  const CompanyLoginPage({super.key});

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
            key: controller.formKey,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  decoration: AppDecorations.bottomSheetDecoration(context),
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

                        // Welcome Text
                        Text(
                          "Company Login 🏢",
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in with your company email and password to access your dashboard.",
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
                          controller: controller.emailController,
                          iconData: CupertinoIcons.mail,
                        ),

                        const SizedBox(height: 12),

                        /// Password Input
                        Obx(
                              () => AppInputTextField(
                            label: "Password",
                            isObscure: controller.isShowPassword.value,
                            validator: FormValidator.password,
                            iconData: CupertinoIcons.lock_fill,
                            controller: controller.passwordController,
                            endIcon: controller.isShowPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            onEndIconTap: () {
                              controller.isShowPassword.toggle();
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.forgotPassword);
                            },
                            child: Text(
                              "Forgot Password?",
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.theme.primaryColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Obx(
                              () => CustomButton(
                            title: "LOGIN",
                            onPressed: controller.performLogin,
                            isLoading: controller.isLoading.value,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Back to options
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              "Back to Login Options",
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
            ),

          ),
        ],
      ),
    );
  }
}