import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/custom_image_view.dart';
import '../controller/edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Edit Profile",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.theme.primaryColor,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: controller.selectedImage.value != null
                            ? Image.file(
                                controller.selectedImage.value!,
                                fit: BoxFit.cover,
                              )
                            : controller.profileImageUrl.value.isNotEmpty
                                ? CustomImageView(
                                    url: controller.profileImageUrl.value,
                                    fit: BoxFit.cover,
                                  )
                                : CustomImageView(
                                    url: "https://img.freepik.com/free-photo/front-view-business-woman-suit_23-2148603018.jpg",
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.pickImage,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Name Field
            _buildTextField(
              controller: controller.nameController,
              label: "Full Name",
              icon: Icons.person_outline,
              hint: "Enter your full name",
            ),

            SizedBox(height: 8),

            // Email Field
            Obx(() => _buildTextField(
              controller: controller.emailController,
              label: "Email",
              icon: Icons.email_outlined,
              hint: controller.canEditEmail.value ? "Enter your email" : "Email cannot be changed",
              keyboardType: TextInputType.emailAddress,
              enabled: controller.canEditEmail.value,
            )),

            SizedBox(height: 8),

            // Phone Field
            Obx(() => _buildTextField(
              controller: controller.phoneController,
              label: "Phone Number",
              icon: Icons.phone_outlined,
              hint: controller.canEditPhone.value ? "Enter your phone number" : "Phone cannot be changed",
              keyboardType: TextInputType.phone,
              enabled: controller.canEditPhone.value,
            )),

            //SizedBox(height: 20),

            // Designation Field
            // _buildTextField(
            //   controller: controller.designationController,
            //   label: "Designation",
            //   icon: Icons.work_outline,
            //   hint: "Enter your designation",
            // ),

            // Address Field
            _buildTextField(
              controller: controller.addressController,
              label: "Address",
              icon: Icons.location_on_outlined,
              hint: "Enter your address",
            ),

            // Gender Field
            _buildTextField(
              controller: controller.genderController,
              label: "Gender",
              icon: Icons.person_outline,
              hint: "Enter your gender",
            ),

            // Aadhaar Number Field
            _buildTextField(
              controller: controller.aadhaarController,
              label: "Aadhaar Number",
              icon: Icons.credit_card_outlined,
              hint: "Enter your aadhaar number",
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 40),

            // Save Button
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            }),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (!enabled) ...[
              SizedBox(width: 8),
              Icon(
                Icons.lock_outline,
                size: 16,
                color: Colors.grey.shade500,
              ),
              SizedBox(width: 4),
              Text(
                "(Locked)",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: enabled ? Colors.grey.shade600 : Colors.grey.shade400),
            suffixIcon: !enabled ? Icon(Icons.lock, color: Colors.grey.shade400, size: 20) : null,
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
