import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/network/api_client.dart';
import 'core/storage/shared_prefs.dart';
import 'features/auth/services/auth_service.dart';
import 'features/location/location_manager.dart';
import 'features/razorpay/payment_repository.dart';
import 'features/razorpay/razorpay_controller.dart';

import 'core/services/sync_service.dart';
import 'core/services/notification_service.dart';
import 'features/trees/data/repository/trees_repository.dart';

Future<void> initApp() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Register repositories and services
  Get.put<ApiClient>(ApiClient(), permanent: true);
  Get.put<TreesRepository>(TreesRepository(), permanent: true);
  Get.put<PaymentRepository>(PaymentRepository(), permanent: true);
  Get.put<RazorpayController>(RazorpayController(), permanent: true);
  
  // Initialize Notification Service
  final notificationService = Get.put(AppNotificationService(), permanent: true);
  await notificationService.init();

  Get.put<SyncService>(SyncService(), permanent: true);







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