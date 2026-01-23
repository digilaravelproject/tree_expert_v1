import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/features/trees/binding/tree_binding.dart';
import 'package:tree_expert/features/trees/presentation/page/add_tree_page.dart';
import '../../features/trees/presentation/page/tree_list_page.dart';

import '../../features/_init/binding/init_binding.dart';
import '../../features/_init/presentation/page/intro_page.dart';
import '../../features/_init/presentation/page/splash_page.dart';
import '../../features/auth/company_login/binding/company_login_binding.dart';
import '../../features/auth/company_login/presentation/page/company_login_page.dart';
import '../../features/auth/company_login/presentation/page/forgot_password_page.dart';
import '../../features/auth/company_login/presentation/page/reset_password_page.dart';
import '../../features/auth/login_mobile/binding/mobile_login_binding.dart';
import '../../features/auth/login_mobile/presentation/page/mobile_login_page.dart';
import '../../features/auth/register/binding/register_binding.dart';
import '../../features/auth/register/presentation/page/register_page.dart';
import '../../features/dashboard/binding/dashboard_binding.dart';
import '../../features/dashboard/presentation/page/dashboard_page.dart';
import '../../features/notification/binding/notification_binding.dart';
import '../../features/notification/presentation/page/notification_page.dart';
import '../../features/profile/binding/profile_binding.dart';
import '../../features/profile/binding/edit_profile_binding.dart';
import '../../features/profile/presentation/page/profile_page.dart';
import '../../features/profile/presentation/page/edit_profile_page.dart';
import '../../features/profile/presentation/page/contact_page.dart';
import '../../features/profile/presentation/page/note_page.dart';
import '../../features/profile/presentation/page/privacy_policy_page.dart';
import '../../features/profile/presentation/page/faq_page.dart';
import '../../features/profile/presentation/page/video_tutorial_page.dart';
import '../../features/projects/binding/projects_binding.dart';
import '../../features/projects/presentation/pages/add_project_tree.dart';
import '../../features/search/binding/search_binding.dart';
import '../../features/search/presentation/page/search_page.dart';
import '../../features/camera/binding/geo_camera_binding.dart';
import '../../features/camera/presentation/page/geo_tag_camera_page.dart';
import '../helper/logger_helper.dart';

class AppRoutes {
  AppRoutes._();

  /// Auth
  static const String splash = '/';
  static const String intro = '/intro';
  static const String mobileLogin = '/mobile-login';
  static const String register = '/register';
  static const String companyLogin = '/company-login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Dashboard Routes
  static const String dashboard = '/dashboard';


  static const String dateProfile = '/dateProfile';
  static const String projectDetails = '/projectDetails';
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String notification = '/notification';
  static const String search = '/search';
  static const String addTrees = '/addTrees';
  static const String addProjects = '/addProjects';
  static const String geoTagCamera = '/geoTagCamera';
  static const String contacts = '/contacts';
  static const String notes = '/notes';
  static const String privacyPolicy = '/privacyPolicy';
  static const String faq = '/faq';
  static const String videoTutorial = '/videoTutorial';


}

class AppPages {
  static List<GetPage> getPages = [
    GetPage(
      binding: InitBinding(),
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      binding: InitBinding(),
      name: AppRoutes.intro,
      page: () => const IntroPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    // Mobile Login Flow
    GetPage(
      name: AppRoutes.mobileLogin,
      transition: Transition.cupertino,
      page: () => const MobileLoginPage(),
      binding: MobileLoginBinding(),
    ),

    // Register
    GetPage(
      name: AppRoutes.register,
      transition: Transition.cupertino,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),

    // Company Login Flow
    GetPage(
      name: AppRoutes.companyLogin,
      transition: Transition.cupertino,
      page: () => const CompanyLoginPage(),
      binding: CompanyLoginBinding(),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      transition: Transition.cupertino,
      page: () => const ForgotPasswordPage(),
      binding: CompanyLoginBinding(),
    ),

    GetPage(
      name: AppRoutes.resetPassword,
      transition: Transition.cupertino,
      page: () => const ResetPasswordPage(),
      binding: CompanyLoginBinding(),
    ),

    // Dashboards
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      bindings: [DashboardBinding(), ProfileBinding(), TreeBinding()],
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      binding: EditProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationPage(),
      binding: NotificationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchPage(),
      binding: SearchBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.addTrees,
      page: () => const AddTreesPage(),
      binding: TreeBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.projectDetails,
      page: () => const TreeDetailsPage(),
      binding: TreeBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.addProjects,
      page: () => const AddProjectPage(),
      binding: ProjectsBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.geoTagCamera,
      page: () => const GeoTagCameraPage(),
      binding: GeoCameraBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.contacts,
      page: () => const ContactPage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.notes,
      page: () => const NotePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => const FaqPage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.videoTutorial,
      page: () => const VideoTutorialPage(),
      binding: ProfileBinding(),
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  StreamSubscription<Uri>? _linkSubscription;

  @override
  RouteSettings? redirect(String? route) {
    _linkSubscription = AppLinks().uriLinkStream.listen((url) {
      printMessage('onAppLink: $url');
    });

    return null;
  }

  @override
  void onPageDispose() {
    _linkSubscription?.cancel();
  }
}
