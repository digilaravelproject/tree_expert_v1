import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';
import 'package:tree_expert/core/styles/theme/app_dark_theme.dart';
import 'package:tree_expert/core/styles/theme/app_light_theme.dart';
import 'package:tree_expert/core/constent/app_constants.dart';
import 'package:tree_expert/core/network/api_checker.dart';
import 'init_app.dart';

Future<void> main() async {
  await initApp();
  runApp(const MyApp());
}

// Global key for SnackBar messages
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Create a global navigator key for ApiChecker
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Set the navigator key for ApiChecker to use for logout navigation
    ApiChecker.navigatorKey = navigatorKey;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppLightTheme.lightTheme,
      //darkTheme: AppDarkTheme.darkTheme, // Use dark theme here
      navigatorKey: navigatorKey, // Add this for ApiChecker navigation
      scaffoldMessengerKey: rootScaffoldMessengerKey, // For global snackbars
      getPages: AppPages.getPages,
      initialRoute: AppRoutes.splash,
    );
  }
}