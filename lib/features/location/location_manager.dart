import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationManager extends GetxController {
  static LocationManager get instance => Get.find();

  // Observables
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxString currentAddress = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool permissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    // checkAndRequestPermission(); // Managed by HomeController
  }

  /// Check and request location permission
  Future<void> checkAndRequestPermission() async {
    try {
      isLoading.value = true;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Services Disabled',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required',
            snackPosition: SnackPosition.BOTTOM,
          );
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied Forever',
          'Please enable location permission from settings',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 4),
        );
        isLoading.value = false;
        return;
      }

      // Permission granted
      permissionGranted.value = true;
      await getCurrentLocation();
      startLocationUpdates();
    } catch (e) {
      print('Permission Error: $e');
      Get.snackbar(
        'Error',
        'Failed to get location permission',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = position;
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      await getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Get Location Error: $e');
      Get.snackbar(
        'Error',
        'Failed to get current location',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get address from coordinates using reverse geocoding
  Future<void> getAddressFromCoordinates(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        currentAddress.value = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }
    } catch (e) {
      print('Geocoding Error: $e');
      currentAddress.value = 'Address not available';
    }
  }

  /// Start continuous location updates
  void startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
        currentPosition.value = position;
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        getAddressFromCoordinates(position.latitude, position.longitude);
      },
      onError: (error) {
        print('Location Stream Error: $error');
      },
    );
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Refresh location manually
  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }
}