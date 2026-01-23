import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class GeoCameraController extends GetxController {
  CameraController? cameraController;
  late List<CameraDescription> _cameras;
  
  var isCameraInitialized = false.obs;
  var isLocationLoaded = false.obs;
  var isCapturing = false.obs;

  // Location Data
  var currentPosition = Rxn<Position>();
  var currentAddress = "Fetching address...".obs;
  var accuracy = "0 m".obs;
  var dateTime = "".obs;

  // Map Data (LatLong2)
  var initialCameraPosition = Rx<LatLng>(LatLng(0, 0));

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
    _getCurrentLocation();
    _updateTime();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        isCameraInitialized.value = true;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to initialize camera: $e");
    }
  }

  void _updateTime() {
    // Determine date time format
    dateTime.value = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check permissions
      var status = await Permission.location.request();
      if (!status.isGranted) {
        Get.snackbar("Permission", "Location permission denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = position;
      accuracy.value = "${position.accuracy.toStringAsFixed(1)} m";
      
      // Update Map Position
      initialCameraPosition.value = LatLng(position.latitude, position.longitude);
      isLocationLoaded.value = true;

      isLocationLoaded.value = true;

      // Get Address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          currentAddress.value = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        }
      } catch (e) {
        currentAddress.value = "Unknown Address";
      }

    } catch (e) {
      Get.snackbar("Error", "Failed to get location: $e");
    }
  }

  Future<String?> captureAndSave({bool saveToGallery = true}) async {
    if (isCapturing.value) return null;
    isCapturing.value = true;

    try {
      // Capture Screenshot of the Stack (Camera + Overlay)
      final Uint8List? imageBytes = await screenshotController.capture();
      
      if (imageBytes == null) {
        Get.snackbar("Error", "Failed to capture image",
          backgroundColor: Colors.red, colorText: Colors.white);
        return null;
      }

      if (saveToGallery) {
        // Request storage permission based on Android version
        bool permissionGranted = false;
        
        // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
        if (await Permission.photos.isGranted || await Permission.mediaLibrary.isGranted) {
          permissionGranted = true;
        } else {
          // Request new permissions
          var photosStatus = await Permission.photos.request();
          var mediaStatus = await Permission.mediaLibrary.request();
          
          if (photosStatus.isGranted || mediaStatus.isGranted) {
            permissionGranted = true;
          } else if (photosStatus.isPermanentlyDenied || mediaStatus.isPermanentlyDenied) {
            Get.snackbar(
              "Permission Required", 
              "Please enable storage permission from app settings",
              backgroundColor: Colors.orange, 
              colorText: Colors.white,
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: Text("Open Settings", style: TextStyle(color: Colors.white)),
              ),
            );
            return null;
          }
        }
        
        // Fallback for older Android versions
        if (!permissionGranted) {
          var storageStatus = await Permission.storage.request();
          if (storageStatus.isGranted) {
            permissionGranted = true;
          } else if (storageStatus.isPermanentlyDenied) {
            Get.snackbar(
              "Permission Required",
              "Please enable storage permission from app settings",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              mainButton: TextButton(
                onPressed: () => openAppSettings(),
                child: Text("Open Settings", style: TextStyle(color: Colors.white)),
              ),
            );
            return null;
          }
        }
        
        if (!permissionGranted) {
          Get.snackbar("Permission Denied", "Storage permission is required to save photos",
            backgroundColor: Colors.orange, colorText: Colors.white);
          return null;
        }

        // Save to Gallery directly from bytes
        final result = await ImageGallerySaverPlus.saveImage(
            imageBytes,
            quality: 100,
            name: "TreeExpert_GeoTag_${DateTime.now().millisecondsSinceEpoch}"
        );
        
        print("Gallery Save Result: $result");

        if (result != null && result['isSuccess'] == true) {
          Get.snackbar("Success", "Photo saved to Gallery!", 
            backgroundColor: Colors.green, colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar("Error", "Failed to save to gallery",
            backgroundColor: Colors.red, colorText: Colors.white);
        }
        return null;
      } else {
        // Save to temporary directory and return path
        print("[GeoCamera] Saving to temp directory (saveToGallery=false)");
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = "TreeExpert_GeoTag_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final String filePath = '${tempDir.path}/$fileName';
        
        final File file = File(filePath);
        await file.writeAsBytes(imageBytes);
        
        print("[GeoCamera] File Saved to Temp: $filePath");
        print("[GeoCamera] Returning to previous screen with file path");
        
        // Return to previous screen with file path immediately
        print("[GeoCamera] Calling Get.back with result: $filePath");
        Get.back(result: filePath);
        
        // Show success message after navigation
        Future.delayed(Duration(milliseconds: 100), () {
          Get.snackbar("Success", "Photo captured!",
            backgroundColor: Colors.green, colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 1));
        });
        
        return filePath;
      }
    } catch (e) {
      print("Capture Error: $e");
      Get.snackbar("Error", "Failed to save photo: $e",
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isCapturing.value = false;
    }
    return null;
  }
}
