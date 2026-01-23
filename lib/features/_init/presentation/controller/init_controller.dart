import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';
import 'package:tree_expert/core/storage/shared_prefs.dart';
import 'package:tree_expert/core/constent/app_constants.dart';

class InitController extends GetxController implements GetTickerProviderStateMixin {
  late AnimationController logoController;

  @override
  void onInit() {
    _initController();
    super.onInit();
  }

  Future<void> startNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedInPref) ?? false;

    if (isLoggedIn) {
      // User is logged in, go to dashboard
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      // Check if intro has been shown before
      bool hasSeenIntro = SharedPrefs.getBool(AppConstants.has_seen_intro) ?? false;

      if (hasSeenIntro) {
        // User has seen intro before, go directly to login_mobile
        Get.offAllNamed(AppRoutes.mobileLogin);
      } else {
        // First time user, show intro
        Get.offAllNamed(AppRoutes.intro);
      }
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  @override
  void didChangeDependencies(BuildContext context) {}

  void _initController() {
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    logoController.dispose();
    super.dispose();
  }
}