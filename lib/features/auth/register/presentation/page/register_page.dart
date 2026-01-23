import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/form_validator.dart';
import '../../../../../core/styles/app_decoration.dart';
import '../../../../../widgets/basic_text_field.dart';
import '../../../../../widgets/custom_buttons.dart';
import '../../../../../widgets/custom_image_view.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../controller/register_controller.dart';

class RegisterPage extends GetWidget<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      enableDoubleTapExit: true,
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: CustomImageView(
                  url:
                      "https://img.freepik.com/premium-photo/tree-field-against-sky-sunset_1048944-27499549.jpg",
                ),
              ),
              SizedBox(height: Get.height * 0.55),
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
                    padding: EdgeInsets.all(16),
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
                        const SizedBox(height: 12),

                        // Welcome Text
                        Text(
                          "Become a Tree Protector 🌍",
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Register with your email Ids to contribute to tree conservation and environmental surveys.",
                        ),

                        Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppInputTextField(
                              label: "Full Name",
                              textInputType: TextInputType.name,
                              validator: FormValidator.name,
                              controller: controller.nameCtrl,
                              iconData: CupertinoIcons.profile_circled,
                            ),

                            Row(
                              spacing: 12,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: AppInputTextField(
                                    label: "Email Id",
                                    textInputType: TextInputType.emailAddress,
                                    validator: FormValidator.email,
                                    controller: controller.emailCtrl,
                                    iconData: CupertinoIcons.mail,
                                  ),
                                ),
                                Expanded(
                                  child: CustomButton(
                                    title: "Verify ",
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),

                            Obx(
                              () => AppInputTextField(
                                label: "Password",
                                isObscure: controller.isPasswordValue.value,
                                validator: FormValidator.password,
                                controller: controller.passwordCtrl,
                                endIcon: controller.isPasswordValue.value
                                    ? Icons.remove_red_eye_rounded
                                    : Icons.visibility_off,
                                iconData: CupertinoIcons.lock_fill,
                                onEndIconTap: controller.isPasswordValue.toggle,
                              ),
                            ),

                            Obx(
                              () => AppInputTextField(
                                label: "Confirm Password",
                                isObscure: controller.isCnfPasswordValue.value,
                                validator: (value) =>
                                    FormValidator.confirmPassword(
                                      value,
                                      controller.passwordCtrl.text,
                                    ),
                                controller: controller.confirmPasswordCtrl,
                                endIcon: controller.isCnfPasswordValue.value
                                    ? Icons.remove_red_eye_rounded
                                    : Icons.visibility_off,
                                iconData: CupertinoIcons.lock,
                                onEndIconTap:
                                    controller.isCnfPasswordValue.toggle,
                              ),
                            ),
                          ],
                        ).marginSymmetric(vertical: 24),

                        /// 🔹 SUBMIT BUTTON
                        CustomButton(
                          onPressed: controller.onRegister,
                          title: "Register",
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
