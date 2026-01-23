import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/network/api_client.dart';
import 'core/storage/shared_prefs.dart';
import 'features/auth/services/auth_service.dart';
import 'features/location/location_manager.dart';

Future<void> initApp() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await SharedPrefs.init();

  // Set preferred orientations (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize ApiClient as a singleton in GetX
  Get.put(ApiClient(), permanent: true);

  // Initialize AuthService
  Get.put(AuthService(), permanent: true);

  // Initialize LocationManager and wait for location permission & data
  final locationManager = Get.put(LocationManager(), permanent: true);
  
  // Wait for location permission and initial location data
  await locationManager.checkAndRequestPermission();
  
  // If permission is granted, wait for location data
  if (locationManager.permissionGranted.value) {
    // Wait until we have latitude, longitude, and address
    int retries = 0;
    while (retries < 5) {
      if (locationManager.latitude.value != 0.0 && 
          locationManager.longitude.value != 0.0 &&
          locationManager.currentAddress.value.isNotEmpty) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      retries++;
    }
  }
}