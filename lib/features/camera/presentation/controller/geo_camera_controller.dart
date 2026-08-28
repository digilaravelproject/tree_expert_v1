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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:async';

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

  // Project/Tree Info (when navigating from Add Tree page)
  var projectNo = "".obs;
  var treeNo = "".obs;
  bool get isFromAddTree => projectNo.value.isNotEmpty;

  // Map Data (LatLong2)
  var initialCameraPosition = Rx<LatLng>(LatLng(0, 0));

  final ScreenshotController screenshotController = ScreenshotController();
  StreamSubscription<Position>? _positionSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
    _getCurrentLocation();
    _updateTime();
    
    // Read project/tree info from arguments (if navigating from Add Tree page)
    final args = Get.arguments;
    if (args is Map) {
      projectNo.value = args['projectNo']?.toString() ?? '';
      treeNo.value = args['treeNo']?.toString() ?? '';
    }
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
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
    dateTime.value = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
  }

  Future<void> _getCurrentLocation() async {
    try {
      var status = await Permission.location.request();
      if (!status.isGranted) {
        Get.snackbar("Permission", "Location permission denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _updatePositionState(position);
      initialCameraPosition.value = LatLng(position.latitude, position.longitude);
      isLocationLoaded.value = true;
      _updateAddress(position);

      late LocationSettings locationSettings;
      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          intervalDuration: const Duration(milliseconds: 500),
        );
      } else if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.best,
          activityType: ActivityType.other,
          distanceFilter: 0,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        );
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position newPosition) {
        _updatePositionState(newPosition);
        // Only update address if we move more than 10 meters to avoid API rate limits
        if (Geolocator.distanceBetween(
              initialCameraPosition.value.latitude,
              initialCameraPosition.value.longitude,
              newPosition.latitude,
              newPosition.longitude) > 10) {
          initialCameraPosition.value = LatLng(newPosition.latitude, newPosition.longitude);
          _updateAddress(newPosition);
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to get location: $e");
    }
  }

  void _updatePositionState(Position position) {
    currentPosition.value = position;
    accuracy.value = "${position.accuracy.toStringAsFixed(1)} m";
  }

  Future<void> _updateAddress(Position position) async {
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
  }

  Future<dynamic> captureAndSave({bool saveToGallery = true}) async {
    if (isCapturing.value) return null;
    isCapturing.value = true;

    try {
      // 1. SAVE THE EXACT COORDINATES CURRENTLY ON THE SCREEN BEFORE THE SCREENSHOT
      final String? capturedLat = currentPosition.value?.latitude?.toStringAsFixed(6);
      final String? capturedLng = currentPosition.value?.longitude?.toStringAsFixed(6);

      // 2. Take the screenshot
      final Uint8List? rawBytes = await screenshotController.capture();
      
      if (rawBytes == null) {
        Get.snackbar("Error", "Failed to capture image",
          backgroundColor: Colors.red, colorText: Colors.white);
        return null;
      }

      // 1. Compress Image to reduce API load and save space
      final Uint8List imageBytes = await FlutterImageCompress.compressWithList(
        rawBytes,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      if (saveToGallery) {
        bool permissionGranted = false;
        if (await Permission.photos.isGranted || await Permission.mediaLibrary.isGranted) {
          permissionGranted = true;
        } else {
          var photosStatus = await Permission.photos.request();
          var mediaStatus = await Permission.mediaLibrary.request();
          if (photosStatus.isGranted || mediaStatus.isGranted) {
            permissionGranted = true;
          }
        }
        
        if (!permissionGranted) {
          var storageStatus = await Permission.storage.request();
          if (storageStatus.isGranted) permissionGranted = true;
        }
        
        if (!permissionGranted) {
          Get.snackbar("Permission Denied", "Storage permission is required",
            backgroundColor: Colors.orange, colorText: Colors.white);
          return null;
        }

        final result = await ImageGallerySaverPlus.saveImage(
            imageBytes,
            quality: 100,
            name: "TreeExpert_GeoTag_${DateTime.now().millisecondsSinceEpoch}"
        );
        
        if (result != null && result['isSuccess'] == true) {
          Get.snackbar("Success", "Photo saved to Gallery!", 
            backgroundColor: Colors.green, colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        }
        return null;
      } else {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = "TreeExpert_GeoTag_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final String filePath = '${tempDir.path}/$fileName';
        
        final File file = File(filePath);
        await file.writeAsBytes(imageBytes);
        
        final Map<String, dynamic> resultMap = {
          'path': filePath,
          'latitude': capturedLat,
          'longitude': capturedLng,
        };
        
        Get.back(result: resultMap);
        
        Future.delayed(Duration(milliseconds: 100), () {
          Get.snackbar("Success", "Photo captured!",
            backgroundColor: Colors.green, colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 1));
        });
        
        return resultMap;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save photo: $e",
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isCapturing.value = false;
    }
    return null;
  }
}
