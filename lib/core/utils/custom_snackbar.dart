import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  /// Show success snackbar
  static void showSuccess({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title ?? 'Success',
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show error snackbar
  static void showError({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      title ?? 'Error',
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title ?? 'Warning',
      message,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.warning, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show info snackbar
  static void showInfo({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title ?? 'Info',
      message,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show custom snackbar
  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      colorText: textColor ?? Colors.white,
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: icon,
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show loading snackbar
  static void showLoading({
    String message = 'Loading...',
    Duration duration = const Duration(seconds: 30),
  }) {
    Get.snackbar(
      '',
      message,
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      showProgressIndicator: true,
      isDismissible: false,
    );
  }

  /// Close current snackbar
  static void close() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  /// Close all snackbars
  static void closeAll() {
    Get.closeAllSnackbars();
  }
}