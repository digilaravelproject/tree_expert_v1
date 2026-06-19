import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:tree_expert/core/helper/country_list_picker.dart';
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
          // Background Image with Overlay
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
          
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: Get.height),
              child: Form(
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
                          mainAxisSize: MainAxisSize.min,
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
                              "Complete your profile to contribute to tree conservation.",
                            ),
                            
                            const SizedBox(height: 20),

                            // Profile Image Picker
                            Center(
                              child: GestureDetector(
                                onTap: controller.pickImage,
                                child: Stack(
                                  children: [
                                    Obx(() {
                                      if (controller.profileImage.value != null) {
                                        return CircleAvatar(
                                          radius: 50,
                                          backgroundImage: FileImage(controller.profileImage.value!),
                                        );
                                      }
                                      return CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey.shade200,
                                        child: Icon(Icons.person, size: 50, color: Colors.grey),
                                      );
                                    }),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: context.theme.primaryColor,
                                        child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

                                 if (controller.loginType == 'email')
                                  Obx(() {
                                    var p = controller.selectedPhone.value;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Mobile Number", style: context.theme.textTheme.labelMedium),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: controller.mobileCtrl,
                                          keyboardType: TextInputType.phone,
                                          maxLength: p.maxLength,
                                          style: context.textTheme.titleMedium,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            counterText: "",
                                            hintText: "Your ${p.maxLength}-digit mobile number",
                                            prefixIcon: Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                                    Text(p.flag, style: const TextStyle(fontSize: 18)),
                                                    Text(
                                                      p.displayCC,
                                                      style: context.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 15),
                                                  ],
                                                ),
                                              ),
                                            ).marginSymmetric(vertical: 12),
                                          ),
                                          validator: (val) => FormValidator.mobile(val, country: p),
                                        ),
                                      ],
                                    );
                                  })
                                else
                                  AppInputTextField(
                                    label: "Email Id",
                                    textInputType: TextInputType.emailAddress,
                                    validator: FormValidator.email,
                                    controller: controller.emailCtrl,
                                    iconData: CupertinoIcons.mail,
                                  ),
                                
                                // Gender Dropdown
                                DropdownButtonFormField<String>(
                                  value: controller.selectedGender.value,
                                  decoration: InputDecoration(
                                     labelText: "Gender",
                                     prefixIcon: Icon(Icons.person_outline),
                                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: ["Male", "Female", "Other"]
                                      .map((label) => DropdownMenuItem(
                                            child: Text(label),
                                            value: label,
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) controller.selectedGender.value = value;
                                  },
                                ),

                                 AppInputTextField(
                                  label: "Address",
                                  textInputType: TextInputType.streetAddress,
                                  validator: (val) => val!.isEmpty ? "Enter address" : null,
                                  controller: controller.addressCtrl,
                                  iconData: CupertinoIcons.location,
                                ),

                                //  AppInputTextField(
                                //   label: "Aadhaar Number",
                                //   textInputType: TextInputType.number,
                                //   maxLength: 12,
                                //   validator: (val) => (val == null || val.length != 12) ? "Enter valid 12-digit Aadhaar" : null,
                                //   controller: controller.aadhaarCtrl,
                                //   iconData: CupertinoIcons.doc_text,
                                // ),
                              ],
                            ).marginSymmetric(vertical: 24),

                            /// 🔹 SUBMIT BUTTON
                            Obx(() => CustomButton(
                              onPressed: controller.onRegister,
                              title: "Complete Profile",
                              isLoading: controller.isLoading.value,
                            )),
                            SizedBox(height: context.mediaQueryPadding.bottom + 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
