import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/utils/app_assets.dart';
import 'package:tree_expert/core/utils/app_dimens.dart';

PreferredSizeWidget buildAppBar({required String title}) {
  return AppBar(
    centerTitle: true,
    leadingWidth: AppDimens.leadingWidth,
    leading: IconButton(
      onPressed: Get.back,
      icon: Icon(AppAssets.backArrow),
      style: IconButton.styleFrom(side: BorderSide.none),
    ),
    title: Text(title),
  );
}
