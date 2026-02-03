import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../data/model/contact_model.dart';
import '../../data/model/faq_model.dart';
import '../../data/model/note_model.dart';
import '../../data/model/privacy_policy_model.dart';
import '../../data/model/user_profile_data.dart';
import '../../data/model/video_tutorial_model.dart';
import '../../data/repository/profile_repository.dart';

class ProfileController extends GetxController {
  RxDouble progress = 0.7.obs;

  /// update progress with animation support
  void setProgress(double value) {
    progress.value = value.clamp(0.0, 1.0);
  }
  // Repository
  final ProfileRepository _profileRepository = ProfileRepository();

  // Observable Data
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final RxList<ContactModel> contacts = <ContactModel>[].obs;
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final Rx<PrivacyPolicyModel?> privacyPolicy = Rx<PrivacyPolicyModel?>(null);
  final RxBool isLoading = false.obs;
  final RxList<FaqModel> faqs = <FaqModel>[].obs;
  final RxInt selectedFaqIndex = (-1).obs;
  final RxList<VideoModel> videos = <VideoModel>[].obs;




  var appVersion = "".obs;

  @override
  void onInit() {
    super.onInit();
    _getAppVersion();
    fetchUserProfile();
    fetchFaqs();
    fetchVideos();
  }

  /// Fetch User Profile
  Future<void> fetchUserProfile() async {
    // Get User ID from prefs
    int? userId = SharedPrefs.getInt(AppConstants.userIdPref); // Assuming you have this pref
    if (userId == null) return;

    isLoading.value = true;
    final response = await _profileRepository.getUserProfile(userId);
    if (response.success && response.data != null) {
      userProfile.value = response.data!;
    }
    isLoading.value = false;
  }

  /// Get App Version
  Future<void> _getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = "Version ${packageInfo.version}";
    } catch (e) {
      appVersion.value = "Version 1.0.0";
    }
  }

  /// Fetch Contacts
  Future<void> fetchContacts() async {
    isLoading.value = true;
    final response = await _profileRepository.getContacts();
    if (response.success && response.data != null) {
      contacts.assignAll(response.data!);
    }
    isLoading.value = false;
  }

  /// Fetch Notes
  Future<void> fetchNotes() async {
    isLoading.value = true;
    final response = await _profileRepository.getNotes();
    if (response.success && response.data != null) {
      notes.assignAll(response.data!);
    }
    isLoading.value = false;
  }

  /// Fetch Privacy Policy
  Future<void> fetchPrivacyPolicy() async {
    isLoading.value = true;
    final response = await _profileRepository.getPrivacyPolicy();
    if (response.success && response.data != null) {
      privacyPolicy.value = response.data!;
    }
    isLoading.value = false;
  }

  /// Open external URL
  void openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        // Use default mode for web URLs (opens in browser)
        // Use externalNonBrowserApplication for tel, mailto, etc
        if (url.startsWith('tel:') || url.startsWith('mailto:') || url.startsWith('sms:')) {
          await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
        } else {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } else {
        Get.snackbar(
          "Error", 
          "Cannot open this link. Please check if you have the required app installed.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Invalid URL: $url",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Share App
  void shareApp() {
    Share.share('Check out Tree Expert App! https://treeexpert.com');
  }

  /// Submit Rating
  Future<void> submitRating(double rating, String comment) async {
    // Get User ID from prefs - target user likely 2 per curl, but here we rate "us" (admin/app). 
    // The previous curl showed rating user_id=2 (likely the provider). 
    // For "Rate App", we might just send feedback or rate a specific admin user.
    // Assuming for now we rate a placeholder or the current user logic is distinct.
    // However, if this is "Rate App", usually it goes to Play Store. 
    // If it's "Feedback", we use an API. 
    // Based on user request "Rate App" menu item -> "api/user/rating"
    int? userId = SharedPrefs.getInt(AppConstants.userIdPref);
    if (userId == null) return;

    isLoading.value = true;
    final response = await _profileRepository.rateUser(userId, rating, comment);
    
    if (response.success) {
      Get.snackbar("Success", "Thank you for your feedback!");
    } else {
      Get.snackbar("Error", response.message ?? "Failed to submit rating");
    }
    isLoading.value = false;
  }

  /// Upload Profile Image
  Future<void> updateProfileImage(String imagePath) async {
    int? userId = SharedPrefs.getInt(AppConstants.userIdPref);
    if (userId == null) return;

    isLoading.value = true;
    final response = await _profileRepository.uploadProfileImage(File(imagePath), userId);
    
    if (response.success) {
      Get.snackbar("Success", "Profile image updated!");
      fetchUserProfile(); // Refresh profile
    } else {
      Get.snackbar("Error", response.message ?? "Failed to upload image");
    }
    isLoading.value = false;
  }

  /// Pick and Upload Image
  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      await updateProfileImage(image.path);
    }
  }

  /// Get FAQ
  Future<void> fetchFaqs() async {
    isLoading.value = true;

    final response = await _profileRepository.getFaqs();

    if (response.success && response.data != null) {
      faqs.assignAll(response.data!);
    }

    isLoading.value = false;
  }


  /// Get Videos
  Future<void> fetchVideos() async {
    isLoading.value = true;

    final response = await _profileRepository.getVideos();

    if (response.success && response.data != null) {
      videos.assignAll(response.data!);
    }

    isLoading.value = false;
  }


}
