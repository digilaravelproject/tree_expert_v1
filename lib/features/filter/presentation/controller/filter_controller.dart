
import 'package:get/get.dart';

class FilterController extends GetxController {
  // Age range
  final RxDouble minAge = 18.0.obs;
  final RxDouble maxAge = 50.0.obs;

  // Distance range (in km)
  final RxDouble maxDistance = 50.0.obs;

  // Looking for
  final RxString lookingFor = 'Everyone'.obs;
  final List<String> lookingForOptions = [
    'Everyone',
    'Men',
    'Women',
    'Non-binary',
  ];

  // Interests
  final RxList<String> selectedInterests = <String>[].obs;
  final List<String> availableInterests = [
    'Travel',
    'Music',
    'Movies',
    'Sports',
    'Reading',
    'Cooking',
    'Art',
    'Gaming',
    'Fitness',
    'Photography',
    'Dancing',
    'Yoga',
    'Fashion',
    'Technology',
    'Food',
    'Nature',
    'Pets',
    'Coffee',
  ];

  // Relationship type
  final RxString relationshipType = 'Any'.obs;
  final List<String> relationshipTypes = [
    'Any',
    'Long-term',
    'Short-term',
    'Friendship',
    'Casual',
  ];

  // Verification status
  final RxBool verifiedOnly = false.obs;

  // Has bio
  final RxBool hasBio = false.obs;

  // Has photos count
  final RxInt minPhotos = 1.obs;

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }

  void resetFilters() {
    minAge.value = 18.0;
    maxAge.value = 50.0;
    maxDistance.value = 50.0;
    lookingFor.value = 'Everyone';
    selectedInterests.clear();
    relationshipType.value = 'Any';
    verifiedOnly.value = false;
    hasBio.value = false;
    minPhotos.value = 1;
  }

  void applyFilters() {
    Get.back();
    Get.snackbar(
      'Filters Applied',
      'Your preferences have been updated',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }
}

