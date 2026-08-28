import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../init_app.dart';
import '../../../../main.dart';
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
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  String? projectName;
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
    _loadPersistedTrees();

    // Listen to girth changes for auto-calculation
    girthController.addListener(_onGirthChanged);

    // Debug listener for tree name controller
    treeNameController.addListener(() {
      print("DEBUG: TreeNameController changed to: '${treeNameController.text}'");
    });

    // Removed continuous background tracking as per user request.
    // Location is now captured once on load and updated only when an image is taken.


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
      if (args.containsKey('projectName')) {
        projectName = args['projectName'].toString();
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

    // Load persisted drafts for this project
    _loadPersistedTrees();
  }

  void _persistLocalTrees() {
    if (projectId == null) return;
    try {
      final String key = "draft_trees_$projectId";
      
      // CRITICAL: Filter out any "ghost" or empty trees from the list 
      // This can happen if user navigated previous/next without filling details
      final List<TreeEntry> validTrees = localTrees.where((entry) {
        return (entry.photos.isNotEmpty) || 
               (entry.girth != null && entry.girth!.isNotEmpty) || 
               (entry.remark != null && entry.remark!.isNotEmpty);
      }).toList();

      final List<String> encoded = validTrees.map((e) => jsonEncode(e.toLocalJson())).toList();
      SharedPrefs.setStringList(key, encoded);
      
      // Update SyncService reactively with the VALID count
      if (Get.isRegistered<SyncService>()) {
        Get.find<SyncService>().updateDraftCount(projectId!, validTrees.length);
      }
      
      print("DEBUG: Persisted ${validTrees.length} VALID trees for project $projectId (Filtered from ${localTrees.length})");
    } catch (e) {
      print("Error persisting trees: $e");
    }
  }

  void _loadPersistedTrees() {
    if (projectId == null) return;
    try {
      final String key = "draft_trees_$projectId";
      final List<String>? encoded = SharedPrefs.getStringList(key);
      if (encoded != null && encoded.isNotEmpty) {
        // Only load if current list is empty to avoid overwriting or duplicates
        if (localTrees.isEmpty) {
          for (String item in encoded) {
            try {
              final Map<String, dynamic> json = jsonDecode(item);
              localTrees.add(TreeEntry.fromLocalJson(json));
            } catch (e) {
              print("Error decoding persisted tree: $e");
            }
          }
          print("DEBUG: Loaded ${localTrees.length} persisted trees for project $projectId");
          
          // If we loaded trees, we should also update the currentTreeNo and possibly other fields
          if (localTrees.isNotEmpty) {
            // Set index to the next one to be added
            currentTreeIndex.value = localTrees.length;
            int baseCount = currentTreesCount;
            currentTreeNo.value = baseCount + localTrees.length + 1;
            treeNoController.text = "${currentTreeNo.value}";
          }
        }
      }
    } catch (e) {
      print("Error loading persisted trees: $e");
    }
  }

  void _updateLocationFields(Position position) {
    // Add null checks to prevent using disposed controllers
    if (_isDisposed) return;
    
    // Lock the location fields once a photo has been captured to ensure
    // the saved coordinates exactly match the photo stamp
    if (capturedPhotos.isNotEmpty) return;
    
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
      // API returns: girth_cm, estimated_height_m, estimated_height_ft, estimated_canopy_m, estimated_canopy_ft, estimated_age_years
      
      if (selectedUnit.value == 'Meter') {
        heightController.text = (data['estimated_height_m'] ?? 0).toString();
        canopyController.text = (data['estimated_canopy_m'] ?? 0).toString();
      } else {
        // Use Feet values from API if available, else convert M to Feet
        if (data.containsKey('estimated_height_ft')) {
          heightController.text = data['estimated_height_ft'].toString();
        } else {
          double heightM = (data['estimated_height_m'] ?? 0).toDouble();
          heightController.text = (heightM * 3.28084).toStringAsFixed(2);
        }

        if (data.containsKey('estimated_canopy_ft')) {
          canopyController.text = data['estimated_canopy_ft'].toString();
        } else {
          double canopyM = (data['estimated_canopy_m'] ?? 0).toDouble();
          canopyController.text = (canopyM * 3.28084).toStringAsFixed(2);
        }
      }
      
      ageController.text = (data['estimated_age_years'] ?? 0).round().toString();
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

  Future<void> addNewTree({
    required String name,
    required String scientificName,
    required String familyName,
  }) async {
    isLoading.value = true;
    
    // Apply fallback if scientific name or family name is empty
    final finalScientific = scientificName.trim().isEmpty ? name : scientificName;
    final finalFamily = familyName.trim().isEmpty ? name : familyName;

    final response = await _treesRepository.addTree(
      name: name,
      scientificName: finalScientific,
      familyName: finalFamily,
    );

    if (response.success && response.data != null) {
      try {
        // Get new tree ID from response: response.data['data']['tree']['id']
        final int? newTreeId = response.data!['data']?['tree']?['id'];
        
        // Refresh the list
        await fetchTrees();
        
        if (newTreeId != null) {
          // Find the new tree in the list and select it
          final newTree = trees.firstWhereOrNull((t) => t.id == newTreeId);
          if (newTree != null) {
            await selectTree(newTree);
          }
        }
        
        Get.back(); // Close bottom sheet
        Get.snackbar("Success", response.message ?? "Tree added successfully", 
            backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        print("Error processing added tree: $e");
        Get.back();
        Get.snackbar("Success", "Tree added, but failed to auto-select. Please select manually.", 
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Error", response.message ?? "Failed to add tree",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading.value = false;
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
        'projectNo': projectName ?? projectId ?? '',
        'treeNo': treeNoController.text,
      },
    );
    
    print("[AddTree] Returned from geo camera. Result: $result");
    print("[AddTree] Result type: ${result.runtimeType}");
    
    if (result != null) {
      String? imagePath;

      if (result is String) {
        imagePath = result;
      } else if (result is Map) {
        imagePath = result['path'];
        
        // Update latitude and longitude to precisely match the image text
        if (result['latitude'] != null) {
          latitudeController.text = result['latitude'];
        }
        if (result['longitude'] != null) {
          longitudeController.text = result['longitude'];
        }
      }

      if (imagePath != null) {
        print("[AddTree] Compressing captured photo: $imagePath");
        
        // Perform compression immediately to reduce future CPU load & heat
        final String? compressedPath = await _compressCapturedImage(imagePath);
        final finalPath = compressedPath ?? imagePath;

        print("[AddTree] Adding photo to list: $finalPath");
        capturedPhotos.add(finalPath);
      } else {
        print("[AddTree] Image path is null in result");
      }
    } else {
      print("[AddTree] Result is null");
    }
  }

  Future<String?> _compressCapturedImage(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final String targetPath = path.replaceAll('.jpg', '_compressed.jpg');
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 1024,
        minHeight: 1024,
        quality: 80,
      );

      return compressedFile?.path;
    } catch (e) {
      print("Error compressing image on capture: $e");
      return null;
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < capturedPhotos.length) {
      capturedPhotos.removeAt(index);
      
      // Resume location updates if all photos are removed
      if (capturedPhotos.isEmpty) {
        _captureGPSLocation();
      }
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
      // Only save if current form has actual data
      // This prevents empty form at the end of list from being saved as 'ghost' draft
      if (_hasCurrentFormData()) {
        _saveCurrentTreeToLocal();
      }
      
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

  bool _validateCurrentForm({bool showError = true}) {
    if (isFetchingDetails.value) {
      if (showError) {
        Get.snackbar("Wait", "Fetching tree details, please wait...",
            snackPosition: SnackPosition.BOTTOM);
      }
      return false;
    }

    // 1. Always required (System requirement)
    if (treeNameController.text.trim().isEmpty) {
      if (showError) {
        Get.snackbar("Required", "Tree name is required",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
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
      if (fieldData.containsKey('is_required') &&
          fieldData['is_required'] is Map) {
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
          if (showError) {
            firstError = "At least one tree image is required";
          } else {
            return false;
          }
          break;
        }
        // Check Min
        if (minValue != null &&
            capturedPhotos.length < (minValue as num).toInt()) {
          if (showError) {
            firstError = "At least $minValue images are required";
          } else {
            return false;
          }
          break;
        }
        // Check Max
        if (maxValue != null &&
            capturedPhotos.length > (maxValue as num).toInt()) {
          if (showError) {
            firstError = "Maximum $maxValue images allowed";
          } else {
            return false;
          }
          break;
        }
        continue;
      }

      // Handling Text Fields and Dropdowns
      if (fieldValues.containsKey(key)) {
        String valueStr =
            fieldValues[key] == null ? "" : fieldValues[key]!.trim();

        // 1. Check Required
        if (isRequired && valueStr.isEmpty) {
          // Skip for scientific_name and family as they have fallbacks to tree_name
          if (key == 'scientific_name' || key == 'family') {
            continue;
          }
          if (showError) {
            firstError = "${_formatFieldName(key)} is required";
          } else {
            return false;
          }
          break;
        }

        // 2. Check Min/Max (Only if value exists)
        if (valueStr.isNotEmpty) {
          final numValue = double.tryParse(valueStr);
          if (numValue != null) {
            if (minValue != null && numValue < (minValue as num).toDouble()) {
              if (showError) {
                firstError =
                    "${_formatFieldName(key)} must be at least $minValue";
              } else {
                return false;
              }
              break;
            }
            if (maxValue != null && numValue > (maxValue as num).toDouble()) {
              if (showError) {
                firstError =
                    "${_formatFieldName(key)} must be at most $maxValue";
              } else {
                return false;
              }
              break;
            }
          }
        }
      }
    }

    if (firstError != null) {
      if (showError) {
        Get.snackbar("Validation Error", firstError,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
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
       plotNo: plotNoController.text,
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

     // print("object")

     if (currentTreeIndex.value < localTrees.length) {
       localTrees[currentTreeIndex.value] = entry;
     } else {
       localTrees.add(entry);
     }
     _persistLocalTrees();
  }

  void _loadTreeFromLocal(int index) {
    if (index >= 0 && index < localTrees.length) {
      final entry = localTrees[index];
      wardPlotNoController.text = entry.wardPlotNo ?? '';
      plotNoController.text = entry.plotNo ?? '';
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

  /// Returns true if there is at least some data in the current form
  bool _hasCurrentFormData() {
    // These are the "active" fields that imply the user started a NEW tree
    // We ignore fields that are auto-filled or kept from previous (like tree name, ward, etc)
    return capturedPhotos.isNotEmpty || 
           girthController.text.isNotEmpty || 
           remarkController.text.isNotEmpty;
  }

  void _resetFormForNext() {
    // Keep Ward/Plot if needed? Usually yes for sequential add.
    // Increment Tree No based on value
    // Parse the numeric part from "T-123"
    int nextNo = currentTreesCount + localTrees.length + 1;
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

  Future<void> saveAsDraftAndExit() async {
    // Only save the current form as a draft if it contains some data
    if (_hasCurrentFormData()) {
      _saveCurrentTreeToLocal();
    }
    
    // Always persist the existing list of successfully added trees
    _persistLocalTrees();
    
    Get.snackbar(
      "Progress Saved",
      _hasCurrentFormData() ? "Draft saved successfully" : "Previous trees safely stored",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.white,
    );
  }

  void discardAllAndExit() {
    localTrees.clear();
    if (projectId != null) {
      SharedPrefs.remove("draft_trees_$projectId");
      if (Get.isRegistered<SyncService>()) {
        Get.find<SyncService>().updateDraftCount(projectId!, 0);
      }
    }
    Get.snackbar(
      "Discarded",
      "All session data has been deleted",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }



  void resetCurrentForm() {
    confirmReset() async {
       final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text("Reset Form?"),
          content: Text("Are you sure you want to clear all data for this tree?"),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: Text("No")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Get.back(result: true), 
              child: Text("Yes, Reset")
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // Clear all controllers
        plotNoController.clear();
        treeNameController.clear();
        selectedTreeId = null;
        scientificNameController.clear();
        selectedScientificNameId = null;
        familyController.clear();
        selectedFamilyId = null;
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
        selectedOwnership.value = 'Pvt';
        
        // Reload location
        _captureGPSLocation();
        
        Get.snackbar("Refreshed", "Form has been cleared", snackPosition: SnackPosition.BOTTOM);
      }
    }
    
    confirmReset();
  }

  Future<void> deleteCurrentTree() async {
    if (localTrees.isEmpty || currentTreeIndex.value >= localTrees.length) {
      Get.snackbar("Error", "Nothing to delete", 
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text("Delete This Tree?"),
        content: Text("Are you sure you want to delete Tree #${currentTreeIndex.value + 1} and re-number the others?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Get.back(result: true), 
            child: Text("Delete")
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 1. Remove from list
    int indexToRemove = currentTreeIndex.value;
    localTrees.removeAt(indexToRemove);

    // 2. Re-number all subsequent trees to maintain sequence
    // currentTreesCount is the baseline count from server
    for (int i = 0; i < localTrees.length; i++) {
       int newTreeNoVal = currentTreesCount + i + 1;
       localTrees[i].treeNo = "$newTreeNoVal";
    }

    // 3. Update navigation state
    if (localTrees.isEmpty) {
      currentTreeIndex.value = 0;
      _resetFormForNext();
    } else {
      // If we deleted the last one, go to the new last one
      if (indexToRemove >= localTrees.length) {
        currentTreeIndex.value = localTrees.length - 1;
      } else {
        // Stay at same index, but now it points to the 'next' tree in the list
        currentTreeIndex.value = indexToRemove;
      }
      _loadTreeFromLocal(currentTreeIndex.value);
    }

    // 4. Update the baseline currentTreeNo for next additions
    currentTreeNo.value = currentTreesCount + localTrees.length + 1;

    // 5. Save changes
    _persistLocalTrees();
    
    Get.snackbar("Deleted", "Tree removed and sequence updated", 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
  }

  Future<void> handleSubmit() async {
    // 1. Try to validate and save the current tree
    if (_validateCurrentForm(showError: false)) {
      // Current tree is valid, save it first
      _saveCurrentTreeToLocal();
      await submitAllStoredTrees();
    } else {
      // Current tree is invalid
      // If we have previously saved trees, submit them
      if (localTrees.isNotEmpty) {
        await submitAllStoredTrees();
      } else {
        // Nothing saved and current is invalid, show the error now
        _validateCurrentForm(showError: true);
      }
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
          TextButton(onPressed: () => Get.back(result: false), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            onPressed: () => Get.back(result: true), 
            child: Text("Submit All")
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 1. Ensure all current data is saved locally first
    _persistLocalTrees();
    
    // 2. Delegate to SyncService for background processing
    if (projectId != null && Get.isRegistered<SyncService>()) {
      Get.find<SyncService>().syncProjectDrafts(projectId!);
      
      // 3. Close the Add Tree screen immediately
      // Note: We use the context and Navigator for more reliability in multi-overlay scenarios
      final context = Get.context;
      if (context != null) {
        Navigator.of(context).pop(true);
      } else {
        Get.back(result: true);
      }
      
      Get.snackbar(
        "Syncing Started", 
        "Submitting ${localTrees.length} trees in background",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } else {
       Get.snackbar("Error", "Sync service not available");
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
