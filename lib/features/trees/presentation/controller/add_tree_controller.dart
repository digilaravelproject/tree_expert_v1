import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../dashboard/presentation/controller/home_controller.dart';
import '../../../location/location_manager.dart';
import '../../../camera/presentation/page/geo_tag_camera_page.dart';
import '../../../camera/presentation/page/geo_tag_camera_page.dart';
import '../../../camera/binding/geo_camera_binding.dart';
import '../../data/repository/trees_repository.dart';
import '../../data/model/tree_model.dart';
import '../../data/model/tree_entry.dart';
import 'dart:async'; // For timer
import 'dart:convert';
import '../../../../core/constent/app_constants.dart';

class AddTreeController extends GetxController {
  final LocationManager locationManager = LocationManager.instance;

  // Form Controllers
  final wardPlotNoController = TextEditingController();
  final plotNoController = TextEditingController();
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
  
  // Selected IDs for Tree selection
  String? selectedTreeId;
  String? selectedScientificNameId;
  String? selectedFamilyId;

  // Observables
  final RxString selectedUnit = 'Feet'.obs; // Meter or Feet
  final RxString selectedCondition = 'Good'.obs;
  final RxString selectedProposedFor = 'Retain'.obs;
  final RxString selectedOwnership = 'Pvt'.obs;
  final RxList<String> capturedPhotos = <String>[].obs; // Multiple photos with paths
  final RxBool isLoading = false.obs;
  final RxBool isFetchingDetails = false.obs;
  final RxInt currentTreeNo = 1.obs;
  final RxMap<String, dynamic> fieldRequirements = <String, dynamic>{}.obs;
  final RxBool isAddMultiple = false.obs;
  
  // IDs
  String? projectId;
  String? userId;
  int? projectLimit; // Maximum trees allowed for this project
  int currentTreesCount = 0; // Current trees in project

  final RxList<TreeModel> trees = <TreeModel>[].obs;
  final RxBool isLoadingTrees = false.obs;
  late final TreesRepository _treesRepository;
  
  Timer? _debounce;
  final RxBool isCalculating = false.obs;

  // Local storage for multi-tree flow
  final RxList<TreeEntry> localTrees = <TreeEntry>[].obs;
  final RxInt currentTreeIndex = 0.obs; // 0-indexed for array, displayed as 1-indexed

  // Add these variables to track subscriptions
  Worker? _positionWorker;
  Worker? _addressWorker;
  bool _isDisposed = false;

  // Check if user can add more trees
  bool get canAddMoreTrees {
    if (projectLimit == null) return true; // No limit set
    int totalTreesAfterCurrent = currentTreesCount + localTrees.length + 1; // +1 for current tree being added
    return totalTreesAfterCurrent < projectLimit!;
  }

  // Check if multiple add should be available
  bool get canAddMultipleTrees {
    if (projectLimit == null) return true; // No limit set
    int totalTreesAfterCurrent = currentTreesCount + localTrees.length + 1; // +1 for current tree
    return totalTreesAfterCurrent < projectLimit!; // Can add more than just the current one
  }

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

  @override
  void onInit() {
    super.onInit();
    _treesRepository = Get.find<TreesRepository>();
    fetchTrees();
    _initializeForm();
    _fetchUserId();
    _fetchFieldRequirements();

    // Listen to girth changes for auto-calculation
    girthController.addListener(_onGirthChanged);

    // Debug listener for tree name controller
    treeNameController.addListener(() {
      print("DEBUG: TreeNameController changed to: '${treeNameController.text}'");
    });

    // Listen to location updates with proper disposal tracking
    _positionWorker = ever(locationManager.currentPosition, (Position? position) {
      if (!_isDisposed && position != null) {
        _updateLocationFields(position);
      }
    });

    // Listen to address updates with proper disposal tracking
    _addressWorker = ever(locationManager.currentAddress, (String address) {
      if (!_isDisposed && address.isNotEmpty) {
        addressController.text = address;
      }
    });
  }

  void _fetchUserId() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        userId = homeController.userId.value.toString();
        print("Fetched User ID from Home: $userId");
      } else {
        // Fallback or retry?
        print("HomeController not found for User ID");
      }
    } catch (e) {
      print("Error fetching user ID: $e");
    }
  }

  void _onGirthChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
       if (girthController.text.isNotEmpty) {
          final girth = double.tryParse(girthController.text);
          if (girth != null) {
            calculateMetrics(girth);
          }
       }
    });
  }

  void _initializeForm() {
    // Get project ID from arguments if passed
    final args = Get.arguments;
    int baseTreeCount = 0;
    
    if (args != null && args is Map) {
      if (args.containsKey('projectId')) {
        projectId = args['projectId'].toString();
      }
      if (args.containsKey('treesCount')) {
         baseTreeCount = int.tryParse(args['treesCount'].toString()) ?? 0;
         currentTreesCount = baseTreeCount;
      }
      if (args.containsKey('limit')) {
         projectLimit = int.tryParse(args['limit'].toString());
      }
      
      // Initial Tree No = base + 1 + currentIndex
      currentTreeNo.value = baseTreeCount + 1 + currentTreeIndex.value;
    }
    
    treeNoController.text = "${currentTreeNo.value}";
    
    // Auto-fill GPS coordinates
    _captureGPSLocation();
  }

  void _updateLocationFields(Position position) {
    // Add null checks to prevent using disposed controllers
    if (_isDisposed) return;
    
    try {
      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);
      accuracyController.text = "${position.accuracy.toStringAsFixed(1)}m";
    } catch (e) {
      print("Error updating location fields: $e");
    }
  }

  // Initial fetch called in _initializeForm
  void _captureGPSLocation() {
    if (locationManager.currentPosition.value != null) {
      _updateLocationFields(locationManager.currentPosition.value!);
    }
    if (locationManager.currentAddress.value.isNotEmpty) {
      addressController.text = locationManager.currentAddress.value;
    }
  }

  Future<void> calculateMetrics(double girthCm) async {
    isCalculating.value = true;
    final response = await _treesRepository.measureTree(girth: girthCm);
    isCalculating.value = false;

    if (response.success && response.data != null) {
      final data = response.data!;
      // API returns: girth_cm, estimated_height_m, estimated_canopy_m, estimated_age_years
      
      if (selectedUnit.value == 'Meter') {
        heightController.text = (data['estimated_height_m'] ?? 0).toString();
        canopyController.text = (data['estimated_canopy_m'] ?? 0).toString();
      } else {
        // Convert M to Feet
        double heightM = (data['estimated_height_m'] ?? 0).toDouble();
        double canopyM = (data['estimated_canopy_m'] ?? 0).toDouble();
        heightController.text = (heightM * 3.28084).toStringAsFixed(2);
        canopyController.text = (canopyM * 3.28084).toStringAsFixed(2);
      }
      
      ageController.text = (data['estimated_age_years'] ?? 0).toString();
    }
  }

  Future<void> fetchTrees() async {
    isLoadingTrees.value = true;
    final response = await _treesRepository.getTrees();
    isLoadingTrees.value = false;

    if (response.success && response.data != null) {
      trees.value = response.data!;
    } else {
      Get.snackbar("Error", response.message ?? "Failed to load trees");
    }
  }

  Future<void> selectTree(TreeModel tree) async {
    print("DEBUG: Selecting tree: ${tree.treeName}");
    
    // Store the values to prevent any accidental clearing
    final treeName = tree.treeName;
    final scientificName = tree.scientificName;
    final family = tree.family;
    
    // 1. Set the text fields immediately
    treeNameController.text = treeName;
    scientificNameController.text = scientificName;
    familyController.text = family;
    
    // Store the IDs properly
    selectedTreeId = tree.id.toString();
    selectedScientificNameId = tree.scientificNameId?.toString();
    selectedFamilyId = tree.familyNameId?.toString();
    
    print("DEBUG: Set text fields - Tree: '${treeNameController.text}', Scientific: '${scientificNameController.text}', Family: '${familyController.text}'");
    print("DEBUG: Set IDs - TreeID: '$selectedTreeId', ScientificID: '$selectedScientificNameId', FamilyID: '$selectedFamilyId'");
    
    // Force update the UI
    update();
    
    // 2. Try to fetch full details in background (optional)
    try {
      isFetchingDetails.value = true;
      final response = await _treesRepository.getTreeDetails(tree.id);
      if (response.success && response.data != null) {
        final details = response.data!;
        
        // Update IDs from API response if available
        selectedTreeId = details.id.toString();
        if (details.scientificNameId != null) {
          selectedScientificNameId = details.scientificNameId.toString();
        }
        if (details.familyNameId != null) {
          selectedFamilyId = details.familyNameId.toString();
        }

        print("DEBUG: Updated IDs from API - TreeID: $selectedTreeId, ScientificID: $selectedScientificNameId, FamilyID: $selectedFamilyId");
        
        // Ensure text fields are still set (defensive programming)
        if (treeNameController.text.isEmpty) {
          treeNameController.text = treeName;
          print("DEBUG: Restored tree name field");
        }
        if (scientificNameController.text.isEmpty) {
          scientificNameController.text = scientificName;
          print("DEBUG: Restored scientific name field");
        }
        if (familyController.text.isEmpty) {
          familyController.text = family;
          print("DEBUG: Restored family field");
        }
      }
    } catch (e) {
      print("Error fetching tree details: $e");
      // Ensure text fields are still set even if API fails
      treeNameController.text = treeName;
      scientificNameController.text = scientificName;
      familyController.text = family;
      print("DEBUG: Restored all fields after API error");
    } finally {
      isFetchingDetails.value = false;
    }
    
    print("DEBUG: Final check - Tree: '${treeNameController.text}', Scientific: '${scientificNameController.text}', Family: '${familyController.text}'");
    print("DEBUG: Final IDs - TreeID: '$selectedTreeId', ScientificID: '$selectedScientificNameId', FamilyID: '$selectedFamilyId'");
  }

  Future<void> capturePhoto() async {
    print("[AddTree] Navigating to geo camera with saveToGallery=false");
    // Navigate to geo-tag camera page with saveToGallery: false
    // Also pass projectId and treeNo to display on camera overlay
    final result = await Get.to(
      () => const GeoTagCameraPage(),
      binding: GeoCameraBinding(),
      arguments: {
        'saveToGallery': false,
        'projectNo': projectId ?? '',
        'treeNo': treeNoController.text,
      },
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
    final currentUnit = selectedUnit.value;
    final newUnit = currentUnit == 'Meter' ? 'Feet' : 'Meter';
    
    // Meters to Feet
    if (newUnit == 'Feet') {
      // Girth: CM -> Inches (REMOVED: Girth always CM)
      // _convertField(girthController, 1 / 2.54); 
      // Height: M -> Feet
      _convertField(heightController, 3.28084);
      // Canopy: M -> Feet
      _convertField(canopyController, 3.28084);
    } 
    // Feet to Meters
    else {
      // Girth: Inches -> CM (REMOVED: Girth always CM)
      // _convertField(girthController, 2.54);
      // Height: Feet -> M
      _convertField(heightController, 1 / 3.28084);
      // Canopy: Feet -> M
      _convertField(canopyController, 1 / 3.28084);
    }

    selectedUnit.value = newUnit;
  }

  void _convertField(TextEditingController controller, double factor) {
    if (controller.text.isEmpty) return;
    double? val = double.tryParse(controller.text);
    if (val != null) {
      controller.text = (val * factor).toStringAsFixed(2);
    }
  }

  // Navigation Logic
  void onPrevious() {
    if (currentTreeIndex.value > 0) {
      _saveCurrentTreeToLocal();
      currentTreeIndex.value--;
      _loadTreeFromLocal(currentTreeIndex.value);
    }
  }

  Future<void> onContinue() async {
    if (_validateCurrentForm()) {

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text("Do you want to save this tree data?"),
          // content: Text("Add ${localTrees.length} ${localTrees.length == 1 ? 'tree' : 'trees'}?"),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: Text("No")),
            ElevatedButton(onPressed: () => Get.back(result: true), child: Text("Yes, Add")),
          ],
        ),
      );

      if (confirmed != true) return;

      _saveCurrentTreeToLocal();
      currentTreeIndex.value++;
      
      // Load next if exists, else reset for new
      if (currentTreeIndex.value < localTrees.length) {
        _loadTreeFromLocal(currentTreeIndex.value);
      } else {
        _resetFormForNext();
      }
    }
  }

  bool _validateCurrentForm() {
    if (isFetchingDetails.value) {
       Get.snackbar("Wait", "Fetching tree details, please wait...", 
          snackPosition: SnackPosition.BOTTOM);
       return false;
    }
    
    // 1. Always required (System requirement)
    if (treeNameController.text.trim().isEmpty) {
      Get.snackbar("Required", "Tree name is required", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
      return false;
    }

    // 2. Dynamic Validations from API
    final req = fieldRequirements;
    // Map field keys to controllers/values
    Map<String, String> fieldValues = {
      'ward_plot_no': wardPlotNoController.text,
      'plot_no': plotNoController.text,
      'tree_no': treeNoController.text,
      'tree_name': treeNameController.text,
      'scientific_name': scientificNameController.text,
      'family': familyController.text,
      'girth': girthController.text,
      'height': heightController.text,
      'canopy': canopyController.text,
      'age': ageController.text,
      'condition': selectedCondition.value,
      'address': addressController.text,
      'landmark': landmarkController.text,
      'ownership': selectedOwnership.value,
      'concern_person': concernPersonController.text,
      'remark': remarkController.text,
    };

    String? firstError;

    // Iterate through requirements provided by API
    for (var entry in req.entries) {
      final key = entry.key;
      final fieldData = entry.value; 
      
      // Handle Nested Structure: "field": { "is_required": { "is_required": true, ... } }
      if (fieldData is! Map) continue;
      
      // Check if 'is_required' key exists and is a Map (The nested object)
      dynamic rules = fieldData; 
      if (fieldData.containsKey('is_required') && fieldData['is_required'] is Map) {
         rules = fieldData['is_required'];
      } else {
         // Fallback if structure is flat (just in case)
         rules = fieldData;
      }

      final isRequired = rules['is_required'] == true;
      final minValue = rules['min_value'];
      final maxValue = rules['max_value'];
      
      // Special Handling for Images
      if (key == 'all_captured_images') {
         // Check Required
         if (isRequired && capturedPhotos.isEmpty) {
            firstError = "At least one tree image is required";
            break;
         }
         // Check Min
         if (minValue != null && capturedPhotos.length < (minValue as num).toInt()) {
            firstError = "At least $minValue images are required";
            break;
         }
         // Check Max
         if (maxValue != null && capturedPhotos.length > (maxValue as num).toInt()) {
            firstError = "Maximum $maxValue images allowed";
            break;
         }
         continue; 
      }

      // Handling Text Fields and Dropdowns
      if (fieldValues.containsKey(key)) {
         String valueStr = fieldValues[key] == null ? "" : fieldValues[key]!.trim();
         
         // 1. Check Required
         if (isRequired && valueStr.isEmpty) {
            firstError = "${_formatFieldName(key)} is required";
            break;
         }
         
         // 2. Check Min/Max (Only if value exists)
         if (valueStr.isNotEmpty) {
            final numValue = double.tryParse(valueStr);
            if (numValue != null) {
               if (minValue != null && numValue < (minValue as num).toDouble()) {
                  firstError = "${_formatFieldName(key)} must be at least $minValue";
                  break;
               }
               if (maxValue != null && numValue > (maxValue as num).toDouble()) {
                  firstError = "${_formatFieldName(key)} must be at most $maxValue";
                  break;
               }
            }
         }
      }
    }

    if (firstError != null) {
      Get.snackbar("Validation Error", firstError, 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
      return false;
    }

    return true;
  }

  String _formatFieldName(String key) {
    return key.split('_').map((e) => e.capitalizeFirst).join(' ');
  }

  final RxBool isWardPlotNoEditable = true.obs;

  Future<void> _fetchFieldRequirements() async {
    if (projectId == null) return;
    
    try {
      String roleId = "";
      String? userDataStr = SharedPrefs.getString(AppConstants.userDataPref);
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        roleId = userData['role_id']?.toString() ?? "";
      }

      final response = await _treesRepository.getTreeRequirements(
        roleId: roleId,
        projectId: projectId!,
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        print("wardPlotNo : "+response.data.toString());
        
        // Handle Ward Number logic
        if (data.containsKey('ward_no') && data['ward_no'] != null) {
          wardPlotNoController.text = data['ward_no'].toString();
          isWardPlotNoEditable.value = false;
        } else {
          isWardPlotNoEditable.value = true;
        }

        // Store requirements
        if (data.containsKey('requirements') && data['requirements'] is Map) {
           fieldRequirements.value = Map<String, dynamic>.from(data['requirements']);
        }
        
        print("Fetched Requirements: $fieldRequirements");
      }
    } catch (e) {
      print("Error fetching requirements: $e");
    }
  }

  void _saveCurrentTreeToLocal() {
     _fetchUserId();
     
     final entry = TreeEntry(
       wardPlotNo: wardPlotNoController.text,
       treeNo: treeNoController.text,
       treeName: treeNameController.text,
       treeId: selectedTreeId,
       scientificName: scientificNameController.text,
       scientificNameId: selectedScientificNameId,
       family: familyController.text,
       familyId: selectedFamilyId,
       girth: girthController.text,
       height: heightController.text,
       canopy: canopyController.text,
       age: ageController.text,
       condition: selectedCondition.value,
       proposedFor: selectedProposedFor.value,
       ownership: selectedOwnership.value,
       address: addressController.text,
       landmark: landmarkController.text,
       concernPerson: concernPersonController.text,
       remark: remarkController.text,
       latitude: latitudeController.text,
       longitude: longitudeController.text,
       accuracy: accuracyController.text,
       unit: selectedUnit.value,
       projectId: projectId,
       userId: userId,
       photos: List.from(capturedPhotos),
     );

     if (currentTreeIndex.value < localTrees.length) {
       localTrees[currentTreeIndex.value] = entry;
     } else {
       localTrees.add(entry);
     }
  }

  void _loadTreeFromLocal(int index) {
    if (index >= 0 && index < localTrees.length) {
      final entry = localTrees[index];
      wardPlotNoController.text = entry.wardPlotNo ?? '';
      treeNoController.text = entry.treeNo ?? '';
      treeNameController.text = entry.treeName ?? '';
      selectedTreeId = entry.treeId;
      scientificNameController.text = entry.scientificName ?? '';
      selectedScientificNameId = entry.scientificNameId;
      familyController.text = entry.family ?? '';
      selectedFamilyId = entry.familyId;
      girthController.text = entry.girth ?? '';
      heightController.text = entry.height ?? '';
      canopyController.text = entry.canopy ?? '';
      ageController.text = entry.age ?? '';
      selectedCondition.value = entry.condition ?? 'Good';
      selectedProposedFor.value = entry.proposedFor ?? 'Retain';
      selectedOwnership.value = entry.ownership ?? 'Pvt';
      addressController.text = entry.address ?? '';
      landmarkController.text = entry.landmark ?? '';
      concernPersonController.text = entry.concernPerson ?? '';
      remarkController.text = entry.remark ?? '';
      latitudeController.text = entry.latitude ?? '';
      longitudeController.text = entry.longitude ?? '';
      accuracyController.text = entry.accuracy ?? '';
      selectedUnit.value = entry.unit ?? 'Meter'; // Restore unit
      capturedPhotos.value = List.from(entry.photos);
    }
  }

  void _resetFormForNext() {
    // Keep Ward/Plot if needed? Usually yes for sequential add.
    // Increment Tree No based on value
    // Parse the numeric part from "T-123"
    int nextNo = currentTreeNo.value + 1; // currentTreeNo is already tracked
    currentTreeNo.value = nextNo; 
    treeNoController.text = "$nextNo";
    
    // Keep tree selection for multiple add - don't clear tree-related fields
    // treeNameController.clear(); // Keep tree name
    // selectedTreeId = null; // Keep selected tree ID
    // scientificNameController.clear(); // Keep scientific name
    // selectedScientificNameId = null; // Keep scientific name ID
    // familyController.clear(); // Keep family
    // selectedFamilyId = null; // Keep family ID
    
    // Clear measurement fields for new tree
    girthController.clear();
    heightController.clear();
    canopyController.clear();
    ageController.clear();
    // landmarkController.clear(); // Keep landmark?
    // concernPersonController.clear(); // Keep?
    remarkController.clear();
    capturedPhotos.clear();
    selectedCondition.value = 'Good';
    selectedProposedFor.value = 'Retain';
    
    // Refresh GPS
    _captureGPSLocation();
  }

  Future<void> handleSubmit() async {
    // 1. Validate the current form first
     if (!_validateCurrentForm()) {
      return; 
    }

    // 2. Check if adding this tree would exceed the limit
    if (!canAddMoreTrees) {
      Get.snackbar(
        "Limit Reached", 
        "Cannot add more trees. Project limit: ${projectLimit ?? 'unlimited'}", 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 3. Save current form logic first
    _saveCurrentTreeToLocal();

    // 4. Check if multiple add is enabled
    if (isAddMultiple.value) {
      // Logic for adding to local array and resetting
      Get.snackbar(
        "Added", 
        "Tree saved to list. You can add more.", 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 1)
      );
      
      // Move index forward
      currentTreeIndex.value++;
      
      // Reset for next
      _resetFormForNext();
      
      // IMPORTANT: Uncheck the multiple add checkbox after adding one tree
      isAddMultiple.value = false;
      
    } else {
      // Logic for submitting everything
      await submitAllStoredTrees();
    }
  }

  Future<void> submitAllStoredTrees() async {
    if (localTrees.isEmpty) {
      Get.snackbar("Error", "No trees to submit");
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text("Confirm Submission"),
        content: Text("Submit ${localTrees.length} ${localTrees.length == 1 ? 'tree' : 'trees'}?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text("No")),
          ElevatedButton(onPressed: () => Get.back(result: true), child: Text("Yes, Submit")),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      // Convert all trees to JSON with base64 images
      final List<Map<String, dynamic>> treesData = [];
      for (TreeEntry entry in localTrees) {
        final jsonData = await entry.toJson();
        treesData.add(jsonData);
      }

      print("treeData with base64 images: $treesData");

      final response = await _treesRepository.submitTrees(treesData);

      isLoading.value = false;

      if (response.success) {
        Get.snackbar("Success", "All trees submitted successfully!");
        
        try {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchProjects();
          }
        } catch (e) {
          print("Error refreshing projects: $e");
        }
        
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(Duration(milliseconds: 300));

        if (Get.context != null) {
          Navigator.of(Get.context!).pop(true);
        } else {
          Get.back(result: true);
        }
      } else {
        Get.snackbar("Error", response.message ?? "Failed to submit trees");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to process images: $e");
      print("Error in submitAllStoredTrees: $e");
    }
  }

  @override
  void onClose() {
    // Mark as disposed first
    _isDisposed = true;
    
    // Cancel timer
    _debounce?.cancel();
    
    // Dispose workers
    _positionWorker?.dispose();
    _addressWorker?.dispose();
    
    // Dispose text controllers
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
