import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../location/location_manager.dart';
import '../../../camera/presentation/page/geo_tag_camera_page.dart';
import '../../../camera/binding/geo_camera_binding.dart';

class AddTreeController extends GetxController {
  final LocationManager locationManager = LocationManager.instance;

  // Form Controllers
  final wardPlotNoController = TextEditingController();
  final treeNoController = TextEditingController();
  final treeNameController = TextEditingController();
  final scientificNameController = TextEditingController();
  final familyController = TextEditingController();
  final girthController = TextEditingController();
  final heightController = TextEditingController();
  final canopyController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  final landmarkController = TextEditingController();
  final concernPersonController = TextEditingController();
  final remarkController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final accuracyController = TextEditingController();

  // Observables
  final RxString selectedUnit = 'Meter'.obs; // Meter or Feet
  final RxString selectedCondition = 'Good'.obs;
  final RxString selectedProposedFor = 'Retain'.obs;
  final RxString selectedOwnership = 'Pvt'.obs;
  final RxList<String> capturedPhotos = <String>[].obs; // Multiple photos with paths
  final RxBool isLoading = false.obs;
  final RxInt currentTreeNo = 1.obs;

  // Dropdown options
  final List<String> conditions = [
    'Poor',
    'Medium',
    'Good',
    'Disease',
    'Dead'
  ];

  final List<String> proposedForOptions = [
    'Cutting',
    'Transplant',
    'Retain',
    'New Plantation'
  ];

  final List<String> ownershipOptions = [
    'Pvt',
    'Gov',
    'Park',
    'Road',
    'Open Space',
    'Riverside'
  ];

  // Tree name suggestions (sample data - should come from API)
  final List<String> treeNameSuggestions = [
    'Neem',
    'Banyan',
    'Peepal',
    'Mango',
    'Teak',
    'Sal',
    'Bamboo',
    'Oak',
    'Pine',
    'Eucalyptus',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }

  void _initializeForm() {
    // Get project ID from arguments if passed
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('projectId')) {
      // TODO: Fetch last tree number for this project and increment
      currentTreeNo.value = 1;
    }
    
    treeNoController.text = currentTreeNo.value.toString();
    
    // Auto-fill GPS coordinates
    _captureGPSLocation();
  }

  void _captureGPSLocation() {
    latitudeController.text = locationManager.latitude.value.toStringAsFixed(6);
    longitudeController.text = locationManager.longitude.value.toStringAsFixed(6);
    accuracyController.text = '10m'; // TODO: Get actual accuracy
    
    // Auto-fill address from location
    if (locationManager.currentAddress.value.isNotEmpty) {
      addressController.text = locationManager.currentAddress.value;
    }
  }

  void onTreeNameChanged(String value) {
    // Auto-fill scientific name and family based on tree name
    // This is sample logic - should fetch from API/database
    switch (value.toLowerCase()) {
      case 'neem':
        scientificNameController.text = 'Azadirachta indica';
        familyController.text = 'Meliaceae';
        break;
      case 'banyan':
        scientificNameController.text = 'Ficus benghalensis';
        familyController.text = 'Moraceae';
        break;
      case 'peepal':
        scientificNameController.text = 'Ficus religiosa';
        familyController.text = 'Moraceae';
        break;
      case 'mango':
        scientificNameController.text = 'Mangifera indica';
        familyController.text = 'Anacardiaceae';
        break;
      default:
        scientificNameController.clear();
        familyController.clear();
    }
  }

  Future<void> capturePhoto() async {
    print("[AddTree] Navigating to geo camera with saveToGallery=false");
    // Navigate to geo-tag camera page with saveToGallery: false
    final result = await Get.to(
      () => const GeoTagCameraPage(),
      binding: GeoCameraBinding(),
      arguments: {'saveToGallery': false},
    );
    
    print("[AddTree] Returned from geo camera. Result: $result");
    print("[AddTree] Result type: ${result.runtimeType}");
    
    if (result != null && result is String) {
      print("[AddTree] Adding photo to list: $result");
      // Add the captured photo path to the list
      capturedPhotos.add(result);
      print("[AddTree] Total photos: ${capturedPhotos.length}");
    } else {
      print("[AddTree] Result is null or not a String");
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < capturedPhotos.length) {
      capturedPhotos.removeAt(index);
    }
  }

  void toggleUnit() {
    selectedUnit.value = selectedUnit.value == 'Meter' ? 'Feet' : 'Meter';
  }

  Future<void> submitTree() async {
    // Validation
    if (treeNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Tree name is required");
      return;
    }

    if (capturedPhotos.isEmpty) {
      Get.snackbar("Error", "Please capture at least one tree photo");
      return;
    }

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text("Confirm Submission"),
        content: Text("Are you sure you want to submit this tree data?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    // TODO: Implement API call to save tree data
    await Future.delayed(Duration(seconds: 2));

    isLoading.value = false;

    Get.snackbar(
      "Success",
      "Tree data submitted successfully!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Increment tree number for next entry
    currentTreeNo.value++;
    _resetForm();
  }

  void _resetForm() {
    treeNoController.text = currentTreeNo.value.toString();
    treeNameController.clear();
    scientificNameController.clear();
    familyController.clear();
    girthController.clear();
    heightController.clear();
    canopyController.clear();
    ageController.clear();
    landmarkController.clear();
    concernPersonController.clear();
    remarkController.clear();
    capturedPhotos.clear();
    selectedCondition.value = 'Good';
    selectedProposedFor.value = 'Retain';
    
    // Keep GPS and address as they likely haven't changed
    _captureGPSLocation();
  }

  @override
  void onClose() {
    wardPlotNoController.dispose();
    treeNoController.dispose();
    treeNameController.dispose();
    scientificNameController.dispose();
    familyController.dispose();
    girthController.dispose();
    heightController.dispose();
    canopyController.dispose();
    ageController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    concernPersonController.dispose();
    remarkController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    accuracyController.dispose();
    super.onClose();
  }
}
