import 'package:flutter/material.dart';

import '../../../../core/styles/app_colors.dart';

class BtmNavModel {
  final String title;
  final IconData icon;
  final IconData? selectedIcon;
  final Color selectedColor;
  final Color unselectedColor;

  const BtmNavModel({
    required this.title,
    required this.icon,
    this.selectedIcon,
    this.selectedColor = AppColors.primary,
    required this.unselectedColor,
  });
}
