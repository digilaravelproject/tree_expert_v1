import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tree_expert/widgets/custom_image_view.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/styles/app_decoration.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../controller/mobile_login_controller.dart';

class MobileLoginPage extends GetWidget<MobileLoginController> {
  const MobileLoginPage({super.key});

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
              SizedBox(height: Get.height * 0.45),
            ],
          ),
          Form(
            key: controller.formKey,
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

                        // Welcome Text
                        Text(
                          "Enter Mobile Number 📱",
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We'll send you an OTP to verify your mobile number.",
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Phone Number Input
                        Text(
                          "Mobile Number",
                          style: context.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 6),

                        Obx(() {
                          var p = controller.selectedPhone.value;
                          return TextFormField(
                            focusNode: FocusNode(canRequestFocus: true),
                            controller: controller.mobileController,
                            maxLength: p.maxLength,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: context.textTheme.titleMedium,

                            decoration: InputDecoration(
                              counterText: "",
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: context.theme.dividerColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: controller.pickCountry,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        p.flag,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        p.displayCC,
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ).marginSymmetric(vertical: 12),
                              hintText: "Your ${p.maxLength}-digit mobile number",
                              hintStyle: context.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          );
                        }),

                        const SizedBox(height: 32),

                        Obx(
                              () => CustomButton(
                            title: "SEND OTP",
                            onPressed: controller.sendOtp,
                            isLoading: controller.isLoading.value,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Back to options
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.companyLogin);
                            },
                            child: Text(
                              "Company Login",
                              style: TextStyle(
                                color: context.theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                       // const SizedBox(height: 8),


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
                        SizedBox(height: 16,),
                        Center(
                          child: Container(
                            //margin: const EdgeInsets.only(bottom: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)], // Premium Green Gradient
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.geoTagCamera);
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(CupertinoIcons.camera_viewfinder, color: Colors.white, size: 22),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Geo Tag Camera",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton:
      // Container(
      //   margin: const EdgeInsets.only(bottom: 20),
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(30),
      //     gradient: const LinearGradient(
      //       colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)], // Premium Green Gradient
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.green.withOpacity(0.4),
      //         blurRadius: 12,
      //         offset: const Offset(0, 6),
      //         spreadRadius: 2,
      //       ),
      //     ],
      //   ),
      //   child: Material(
      //     color: Colors.transparent,
      //     child: InkWell(
      //       onTap: () {
      //         Get.toNamed(AppRoutes.geoTagCamera);
      //       },
      //       borderRadius: BorderRadius.circular(30),
      //       child: Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      //         child: Row(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             const Icon(CupertinoIcons.camera_viewfinder, color: Colors.white, size: 22),
      //             const SizedBox(width: 10),
      //             const Text(
      //               "Geo Tag Camera",
      //               style: TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.w600,
      //                 letterSpacing: 0.5,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}