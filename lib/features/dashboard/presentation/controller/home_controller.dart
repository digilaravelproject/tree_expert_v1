import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constent/app_constants.dart';
import '../../../../core/storage/shared_prefs.dart';
import '../../../../packages/card_swiper/src/controller/card_swiper_controller.dart';
import '../../../../packages/card_swiper/src/direction/card_swiper_direction.dart';
import '../../../location/location_manager.dart';
import '../../../projects/data/models/project_data_model.dart';
import '../../../projects/data/model/project_list_model.dart';
import '../../../projects/data/repository/projects_repository.dart';
import '../../data/model/user_profile_data.dart';
import '../../data/repository/dashboard_repository.dart';

class HomeController extends GetxController {

  // Location Manager instance
  final locationManager = LocationManager.instance;

  // User data
  final RxString userName = 'User'.obs;
  final RxString userEmail = ''.obs;
  final RxInt userId = 0.obs;

  final List<Project> projects = [
    Project(
      name: "Green Earth Initiative",
      state: "California",
      district: "San Francisco",
      treesCount: 12500,
      startDate: DateTime(2023, 1, 1),
      endDate: DateTime(2025, 12, 31),
    ),
    Project(
      name: "Urban Forest Project",
      state: "New York",
      district: "Manhattan",
      treesCount: 8500,
      startDate: DateTime(2022, 6, 1),
      endDate: DateTime(2024, 12, 31),
    ),
    Project(
      name: "Coastal Restoration",
      state: "Florida",
      district: "Miami-Dade",
      treesCount: 21000,
      startDate: DateTime(2024, 3, 1),
      endDate: DateTime(2026, 11, 30),
    ),
  ];

  // Dashboard Repository
  final DashboardRepository _dashboardRepository = DashboardRepository();
  final ProjectsRepository _projectsRepository = ProjectsRepository();

  // Observable stats
  final RxInt projectCount = 0.obs;
  final RxInt treeCount = 0.obs;
  final RxInt districtCount = 0.obs;
  final RxBool isLoadingStats = false.obs;

  // Observable projects
  final RxList<ProjectListModel> projectsList = <ProjectListModel>[].obs;
  final RxBool isLoadingProjects = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load users data from local storage
    _loadUserData();
    
    // Check location strictly before fetching data
    _ensureLocationAndFetchData();
  }

  Future<void> _ensureLocationAndFetchData() async {
    // 1. Check Service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return; 
    }

    // 2. Check Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentDialog();
      return;
    }

    // 3. If Valid, Proceed
    await locationManager.getCurrentLocation();
    _fetchDashboardStats();
    _fetchProjects();
  }

  void _showLocationServiceDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text("Location Required"),
          content: Text("Please enable location services to use the app."),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                // Start checking in background
                _startLocationServiceCheck();
              },
              child: Text("Enable"),
            ),
            TextButton(
              onPressed: () async {
                 // Check status before closing logic
                 bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                 if (serviceEnabled) {
                   Get.back();
                   _ensureLocationAndFetchData();
                 } else {
                   Get.snackbar("Location Required", "Please enable location services first.", 
                     snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(10));
                 }
              },
               child: Text("Retry"),
            )
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Periodically check if location service is enabled
  void _startLocationServiceCheck() {
    Future.delayed(Duration(seconds: 1), () async {
      if (Get.isDialogOpen ?? false) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          Get.back(); // Close dialog
          _ensureLocationAndFetchData();
        } else {
          _startLocationServiceCheck(); // Check again
        }
      }
    });
  }

  void _showPermissionDeniedDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text("Permission Required"),
          content: Text("Location permission is needed to fetch local data."),
          actions: [
            TextButton(
              onPressed: () async {
                // Request permission directly
                LocationPermission permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
                  Get.back();
                  _ensureLocationAndFetchData();
                } else if (permission == LocationPermission.deniedForever) {
                   Get.back();
                   _ensureLocationAndFetchData(); // Will trigger permanent dialog
                } else {
                  Get.snackbar("Permission Denied", "Please grant location permission",
                    snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(10));
                }
              },
              child: Text("Grant"),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showPermissionPermanentDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text("Permission Required"),
          content: Text("Location permission is permanently denied. Please enable it in App Settings."),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openAppSettings();
                // Start checking in background
                _startPermissionCheck();
              },
              child: Text("Open Settings"),
            ),
            TextButton(
               onPressed: () async {
                 LocationPermission permission = await Geolocator.checkPermission();
                 if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
                   Get.back();
                   _ensureLocationAndFetchData();
                 } else {
                   Get.snackbar("Permission Required", "Please enable location permission from settings",
                     snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(10));
                 }
               },
               child: Text("Retry"),
            )
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Periodically check if permission is granted
  void _startPermissionCheck() {
    Future.delayed(Duration(seconds: 1), () async {
      if (Get.isDialogOpen ?? false) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          Get.back(); // Close dialog
          _ensureLocationAndFetchData();
        } else {
          _startPermissionCheck(); // Check again
        }
      }
    });
  }

  Future<void> _fetchDashboardStats() async {
    isLoadingStats.value = true;
    final response = await _dashboardRepository.getDashboardStats();
    
    if (response.success && response.data != null) {
      projectCount.value = response.data!.projectCount;
      treeCount.value = response.data!.treeCount;
      districtCount.value = response.data!.districtCount;
    } else {
      print("Failed to fetch dashboard stats: ${response.message}");
    }
    isLoadingStats.value = false;
  }

  /// Load user data from SharedPreferences
  void _loadUserData() {
    try {
      // Get user data from shared preferences
      final userDataString = SharedPrefs.getString(AppConstants.userDataPref);
      final userIdValue = SharedPrefs.getInt(AppConstants.userIdPref);

      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = jsonDecode(userDataString);
        userName.value = userData['name'] ?? 'User';
        userEmail.value = userData['email'] ?? '';
      }

      if (userIdValue != null) {
        userId.value = userIdValue;
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback: Try to parse the legacy Dart map string format
      // Format: {id: 9, name: Sachin Kumar, email: ...}
      try {
        final userDataString = SharedPrefs.getString(AppConstants.userDataPref);
        if (userDataString != null) {
          // Extract name using regex
          final nameMatch = RegExp(r'name:\s*([^,]+)(?:,|})').firstMatch(userDataString);
          if (nameMatch != null && nameMatch.group(1) != null) {
            final extractedName = nameMatch.group(1)!.trim();
            print("Fallback matched name: $extractedName");
            userName.value = extractedName;
          }
          
           // Extract email using regex
          final emailMatch = RegExp(r'email:\s*([^,]+)(?:,|})').firstMatch(userDataString);
          if (emailMatch != null && emailMatch.group(1) != null) {
            userEmail.value = emailMatch.group(1)!.trim();
          }
        }
      } catch (fallbackError) {
         print('Fallback parsing failed: $fallbackError');
         userName.value = 'User';
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    // You can access location data here
    ever(locationManager.currentAddress, (address) {
      print('Address Updated: $address');
    });
  }

  // Get current location data
  String get currentAddress => locationManager.currentAddress.value;
  double get currentLatitude => locationManager.latitude.value;
  double get currentLongitude => locationManager.longitude.value;

  /// Fetch projects from API
  Future<void> _fetchProjects() async {
    isLoadingProjects.value = true;
    final response = await _projectsRepository.getProjectList();
    
    if (response.success && response.data != null) {
      projectsList.value = response.data!;
    } else {
      print("Failed to fetch projects: ${response.message}");
    }
    isLoadingProjects.value = false;
  }

  /// Refresh projects (for pull-to-refresh)
  Future<void> refreshProjects() async {
    // Refresh connection and data
    _ensureLocationAndFetchData();
  }

  // Get greeting message based on time
  String get greetingMessage {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Refresh location manually
  Future<void> refreshLocation() async {
     _ensureLocationAndFetchData();
  }
}