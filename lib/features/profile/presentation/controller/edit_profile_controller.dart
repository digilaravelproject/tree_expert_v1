import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/helper/country_list_picker.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../data/repository/profile_repository.dart';
import '../controller/profile_controller.dart';

class EditProfileController extends GetxController {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ProfileController _profileController = Get.find<ProfileController>();

  // Form Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final designationController = TextEditingController();
  final addressController = TextEditingController();
  final aadhaarController = TextEditingController();
  final genderController = TextEditingController();

  // Observable
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxString profileImageUrl = ''.obs;
  
  // Track if fields can be edited
  final RxBool canEditEmail = true.obs;
  final RxBool canEditPhone = true.obs;
  
  final selectedPhone = countries.firstWhere((c) => c.code == "IN").obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    if (_profileController.userProfile.value != null) {
      final profile = _profileController.userProfile.value!;
      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone ?? '';
      designationController.text = profile.designation ?? '';
      addressController.text = profile.address ?? '';
      aadhaarController.text = profile.aadhaarNumber ?? '';
      genderController.text = profile.gender ?? '';
      profileImageUrl.value = profile.profileImage ?? '';
      
      // Attempt to find country by dial code if phone exists
      if (profile.phone != null && profile.phone!.startsWith('+')) {
          final dialCode = profile.phone!.split(' ')[0]; // Assuming format "+91 1234567890"
          final match = countries.firstWhereOrNull((c) => c.displayCC == dialCode);
          if (match != null) {
              selectedPhone.value = match;
              // If phone is stored as "+91 9876543210", we might want to strip the prefix for the controller
              if (profile.phone!.contains(' ')) {
                  phoneController.text = profile.phone!.split(' ').sublist(1).join(' ');
              }
          }
      }

      // Determine if fields can be edited
      canEditEmail.value = profile.email.isEmpty;
      canEditPhone.value = profile.phone?.isEmpty ?? true;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // Pick Country
  void pickCountry() {
    Get.to(() => CountriesList(onTap: (country) {
      selectedPhone.value = country;
    }));
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Name is required");
      return;
    }

    // Validate email if it's editable and filled
    if (canEditEmail.value && emailController.text.trim().isNotEmpty) {
      if (!GetUtils.isEmail(emailController.text.trim())) {
        Get.snackbar("Error", "Please enter a valid email");
        return;
      }
    }

    // Validate phone if it's editable and filled
    if (canEditPhone.value && phoneController.text.trim().isNotEmpty) {
      if (phoneController.text.trim().length < 10) {
        Get.snackbar("Error", "Please enter a valid phone number");
        return;
      }
    }

    isLoading.value = true;

    try {
      int? userId = SharedPrefs.getInt(AppConstants.userIdPref);
      if (userId == null) {
        Get.snackbar("Error", "User ID not found");
        isLoading.value = false;
        return;
      }

      print("Starting profile update for user: $userId");

      // Prepare update data
      Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'designation': designationController.text.trim(),
        'address': addressController.text.trim(),
        'gender': genderController.text.trim(),
        'aadhaar_number': aadhaarController.text.trim(),
        'mobile': phoneController.text.trim(), // Use 'mobile' as per API
        'phone_code': selectedPhone.value.displayCC,
      };

      // Always include email - use current profile email if field is not editable
      if (canEditEmail.value && emailController.text.trim().isNotEmpty) {
        updateData['email'] = emailController.text.trim();
      } else {
        // Use existing email from profile
        updateData['email'] = _profileController.userProfile.value?.email ?? '';
      }

      // Add phone if editable and not empty, otherwise use existing phone
      if (canEditPhone.value && phoneController.text.trim().isNotEmpty) {
        updateData['phone'] = phoneController.text.trim();
      } else if (_profileController.userProfile.value?.phone != null) {
        updateData['phone'] = _profileController.userProfile.value!.phone!;
      }

      bool apiSuccess = false;

      // If image is selected, use the combined upload method
      if (selectedImage.value != null) {
        print("Uploading profile with image");
        final imageResponse = await _profileRepository.uploadProfileImage(
          selectedImage.value!,
          userId,
          nameController.text.trim(),
          canEditEmail.value ? emailController.text.trim() : (_profileController.userProfile.value?.email ?? ''),
          address: addressController.text.trim(),
          gender: genderController.text.trim(),
          aadhaarNumber: aadhaarController.text.trim(),
          mobile: phoneController.text.trim(),
          phoneCode: selectedPhone.value.displayCC,
        );

        if (!imageResponse.success) {
          print("Image upload failed: ${imageResponse.message}");
          Get.snackbar(
            "Error", 
            imageResponse.message ?? "Failed to update profile",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
        apiSuccess = true;
        print("Image upload successful");
      } else {
        print("Updating profile without image");
        // Update profile data without image
        final response = await _profileRepository.updateProfile(userId, updateData);
        
        if (!response.success) {
          print("Profile update failed: ${response.message}");
          Get.snackbar(
            "Error", 
            response.message ?? "Failed to update profile",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
        apiSuccess = true;
        print("Profile update successful");
      }

      if (apiSuccess) {
        print("Refreshing profile data");
        // Refresh profile data first
        await _profileController.fetchUserProfile();
        print("Profile data refreshed");

        print("Going back to previous screen");
        // Try multiple navigation methods
        try {
          Get.back();
          print("Get.back() executed successfully");
        } catch (e) {
          print("Get.back() failed: $e");
          // Try alternative navigation
          if (Get.context != null) {
            Navigator.of(Get.context!).pop();
            print("Navigator.pop() executed");
          }
        }

        // Show success message after navigation
        Get.snackbar(
          "Success",
          "Profile updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print("Error in saveProfile: $e");
      Get.snackbar("Error", "Failed to update profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    designationController.dispose();
    addressController.dispose();
    aadhaarController.dispose();
    genderController.dispose();
    super.onClose();
  }
}
