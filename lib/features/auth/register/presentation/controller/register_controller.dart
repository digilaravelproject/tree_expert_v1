import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tree_expert/core/routes/app_routes.dart';
import 'package:tree_expert/core/storage/shared_prefs.dart';
import 'package:tree_expert/core/constent/app_constants.dart';
import 'dart:convert';

import 'package:tree_expert/core/helper/country_list_picker.dart';
import '../../../services/auth_service.dart';
import '../../data/model/register_req.dart';
import '../../domain/usecase/register_user_usecase.dart';

class RegisterController extends GetxController {
  // Auth Service
  final AuthService authService;

  // Use Case (kept for compatibility)
  final RegisterUserUseCase registerUserUseCase;

  RegisterController({
    required this.authService,
    required this.registerUserUseCase,
  });

  // Form Key
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final isEmailVerified = false.obs;
  final selectedGender = 'Male'.obs;
  final profileImage = Rx<File?>(null);
  final selectedPhone = countries.firstWhere((c) => c.code == "IN").obs;

  // Get phone/email from previous screen
  String? phoneNumber;
  String? emailAddress;
  String? phoneCountryCode;
  String? loginType;
  Map<String, dynamic>? userData;

  @override
  void onInit() {
    super.onInit();
    // Get data from arguments if passed
    final args = Get.arguments;
    if (args != null) {
      phoneNumber = args['phone'];
      emailAddress = args['email'];
      phoneCountryCode = args['phoneCode'];
      loginType = args['loginType'];
      userData = args['user'];
      
      if (phoneCountryCode != null) {
          // Attempt to find country by dial code
          final match = countries.firstWhereOrNull((c) => c.displayCC == phoneCountryCode);
          if (match != null) selectedPhone.value = match;
      }
      
      if (phoneNumber != null) mobileCtrl.text = phoneNumber!;
      if (emailAddress != null) emailCtrl.text = emailAddress!;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    aadhaarCtrl.dispose();
    super.onClose();
  }
  // Pick Country
  void pickCountry() {
    Get.to(() => CountriesList(onTap: (country) {
      selectedPhone.value = country;
    }));
  }

  // Pick Image
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  // Register User / Complete Profile
  Future<void> onRegister() async {
    if (!formKey.currentState!.validate()) return;

    if (aadhaarCtrl.text.length != 12) {
      Get.snackbar("Error", "Aadhaar number must be 12 digits",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      if (userData == null) {
        Get.snackbar("Error", "User details not found. Please login again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }
      
      String userId = userData!['id'].toString();

      final result = await authService.completeUserProfile(
        userId: userId,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        mobile: mobileCtrl.text.trim(), // Added mobile field
        gender: selectedGender.value.toLowerCase(),
        aadhaarNumber: aadhaarCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        profileImage: profileImage.value,
      );

      if (result.success) {
        Get.snackbar(
          "Success",
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Update local user data with new details if needed
        // Assuming the API returns updated user object, we can update SharedPrefs
        if (result.data != null && result.data is Map<String, dynamic> && result.data!.containsKey('user')) {
             await SharedPrefs.setString(
              AppConstants.userDataPref,
              jsonEncode(result.data!['user']),
            );
        }

        // Navigate to Dashboard
        Get.offAllNamed(AppRoutes.dashboard);
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
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
