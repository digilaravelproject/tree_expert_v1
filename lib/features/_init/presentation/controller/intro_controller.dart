import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/constent/app_constants.dart';
import 'package:tree_expert/core/storage/shared_prefs.dart';
import 'package:tree_expert/core/utils/app_assets.dart';

import '../../data/model/intro_item_model.dart';

class IntroController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  // Static intro screens data for tree conservation app
  final introItems = <IntroItemModel>[
    IntroItemModel(
      id: 1,
      title: "Survey Trees",
      description: "Document and map trees in your area with precision GPS tracking and comprehensive data collection",
      image: AppAssets.imgIntro1, // Replace with your actual asset
      order: 1,
    ),
    IntroItemModel(
      id: 2,
      title: "Monitor Health",
      description: "Track tree health, growth patterns, and environmental conditions to ensure proper conservation",
      image: AppAssets.imgIntro2, // Replace with your actual asset
      order: 2,
    ),
    IntroItemModel(
      id: 3,
      title: "Protect & Preserve",
      description: "Join a community of tree experts dedicated to preserving our natural heritage for future generations",
      image: AppAssets.imgIntro3, // Replace with your actual asset
      order: 3,
    ),
  ].obs;

  @override
  void onInit() {
    _initController();
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _initController() {
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
  }

  // Mark intro as seen when user completes it
  void markIntroAsSeen() {
    SharedPrefs.setBool(AppConstants.has_seen_intro, true);
  }
}

