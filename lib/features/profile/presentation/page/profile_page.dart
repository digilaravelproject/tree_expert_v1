import 'package:tree_expert/core/routes/app_routes.dart';
import 'package:tree_expert/core/styles/app_colors.dart';
import 'package:tree_expert/core/styles/app_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../features/dashboard/presentation/controller/home_controller.dart';
import '../../../../features/auth/services/auth_service.dart';
import '../controller/profile_controller.dart';
import '../controller/payslip_controller.dart';
import '../widget/rating_dialog.dart';
import 'payslip_page.dart';

class ProfilePage extends GetWidget<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back),
        ),
        // leading: SizedBox.square(
        //   dimension: 40,
        //   child: Padding(
        //     padding: const EdgeInsets.all(12.0),
        //     child: ClipOval(
        //       child: CustomImageView(
        //         imagePath: AppAssets.imgAppLogo,
        //         fit: BoxFit.fill,
        //       ),
        //     ),
        //   ),
        // ),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24),
            // Profile Image & Info
            Center(
              child: Column(
                children: [
                   GestureDetector(
                    onTap: () => controller.pickAndUploadImage(),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Obx(() {
                               if (controller.userProfile.value != null && controller.userProfile.value!.profileImage != null) {
                                  return CustomImageView(
                                    url: controller.userProfile.value!.profileImage,
                                    fit: BoxFit.cover,
                                  );
                               }
                               return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: Icon(Icons.person, size: 50, color: Colors.grey.shade400),
                              );
                            }),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.theme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)
                            ),
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() {
                    // Prefer ProfileController data, fallback to HomeController
                    String name = "User";
                    String email = "email@example.com";
                    
                    if (controller.userProfile.value != null) {
                        name = controller.userProfile.value!.name;
                        email = controller.userProfile.value!.email;
                    } else {
                        final homeController = Get.find<HomeController>();
                        name = homeController.userName.value;
                        email = homeController.userEmail.value;
                    }

                     return Column(
                      children: [
                        Text(
                          name,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            email.isEmpty ? "email@example.com" : email,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // SECTION 1: Profile Actions
                  _buildMenuItem(
                    context,
                    icon: Icons.edit_outlined,
                    title: "Edit Profile",
                    onTap: () => Get.toNamed(AppRoutes.editProfile),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: "Payslip",
                    onTap: () => Get.to(() => PayslipPage(), binding: BindingsBuilder(() {
                      Get.lazyPut(() => PayslipController());
                    })),
                  ),
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.notifications_none,
                  //   title: "Notification",
                  // //  subtitle: "Coming Soon",
                  //   onTap: () => Get.toNamed(AppRoutes.notification)
                  //       //Get.snackbar("Coming Soon", "Notification feature will be available soon!"),
                  // ),
                  
                  Divider(height: 32),
                  
                  // SECTION 2: Help & Support
                  _buildMenuItem(
                    context,
                    icon: Icons.perm_contact_calendar_outlined,
                    title: "Contact",
                    onTap: () => Get.toNamed(AppRoutes.contacts),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.note_alt_outlined,
                    title: "Note",
                    onTap: () => Get.toNamed(AppRoutes.notes),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: "FAQ",
                   // subtitle: "Coming Soon",
                    onTap: () => Get.toNamed(AppRoutes.faq),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.play_circle_outline,
                    title: "Video Tutorial",
                  //  subtitle: "Coming Soon",
                    onTap: () => Get.toNamed(AppRoutes.videoTutorial),
                  ),
                  
                  Divider(height: 32),
                  
                  // SECTION 3: App Info
                  _buildMenuItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.star_border,
                    title: "Rate App",
                    onTap: () {
                        Get.dialog(RatingDialog());
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.share_outlined,
                    title: "Share App",
                    onTap: () => controller.shareApp(),
                  ),
                  
                  Divider(height: 32),
                  
                  // SECTION 4: Logout
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: "Logout",
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () async {
                      final confirm = await LogoutDialog.show(
                        context: context,
                        title: 'Confirm Logout',
                        message: 'You will be redirected to the login screen.',
                      );
                      if (confirm == true) {
                        Get.find<AuthService>().logout();
                      }
                    },
                    // onTap: () {
                    //   Get.find<AuthService>().logout();
                    // },
                  ),


                  // _SettingsItem(
                  //   title: 'Logout',
                  //   icon: Icons.logout_rounded,
                  //   isDestructive: true,
                  //   onTap: () async {
                  //     final confirm = await LogoutDialog.show(
                  //       context: context,
                  //       title: 'Confirm Logout',
                  //       message: 'You will be redirected to the login screen.',
                  //     );
                  //     if (confirm == true) {
                  //       authService.logout();
                  //     }
                  //   },
                  // ),

                  const SizedBox(height: 40),
                  
                  // App Version Display
                  Obx(() => Text(
                    controller.appVersion.value,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? context.theme.iconTheme.color)?.withOpacity(0.1) ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? context.theme.iconTheme.color,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: context.textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}





class LogoutDialog {
  static Future<bool?> show({
    required BuildContext context,
    String title = 'Log Out',
    String message = 'Are you sure you want to log out?',
    String confirmText = 'Log Out',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.red,
    Color cancelColor = Colors.grey,
    bool showIcon = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 28,
                      color: Colors.red,
                    ),
                  ),
                if (showIcon) const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cancelColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: confirmColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
