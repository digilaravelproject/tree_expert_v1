import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/widgets/custom_image_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/services/auth_service.dart';
import '../controller/home_controller.dart';

class ProfileBottomSheet extends StatelessWidget {
  final HomeController controller;

  const ProfileBottomSheet({super.key, required this.controller});

  static void show(HomeController controller) {
    Get.bottomSheet(
      ProfileBottomSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),

            // Profile Image
            Stack(
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
                    child: Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: Icon(Icons.person, size: 50, color: Colors.grey.shade400),
                    ),
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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      CupertinoIcons.pencil,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // User Name
            Obx(
              () => Text(
                controller.userName.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            SizedBox(height: 6),

            // Email
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.userEmail.value.isEmpty 
                      ? "email@example.com" 
                      : controller.userEmail.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Menu Options
            _buildMenuItem(
              icon: CupertinoIcons.person,
              title: "Edit Profile",
              onTap: () {
                Get.back();
                Get.toNamed('/profile');
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.lock,
              title: "Add Pin",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Add Pin feature coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.settings,
              title: "Settings",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Settings feature coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.person_add,
              title: "Invite a Friend",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Invite feature coming soon");
              },
            ),

            Divider(height: 1, thickness: 1),

            _buildMenuItem(
              icon: CupertinoIcons.star,
              title: "Rate App",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Rate App feature coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.share,
              title: "Share App",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Share App feature coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.doc_text,
              title: "Privacy Policy",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Privacy Policy coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.mail,
              title: "Contact",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Contact feature coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.play_circle,
              title: "Video Tutorial",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Video Tutorial coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.doc,
              title: "Note",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "Note feature coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.question_circle,
              title: "FAQ",
              onTap: () {
                Get.back();
                Get.snackbar("Info", "FAQ coming soon");
              },
            ),
            _buildMenuItem(
              icon: CupertinoIcons.chat_bubble_2,
              title: "Customer Care (WhatsApp)",
              onTap: () async {
                Get.back();
                // Replace with your WhatsApp number
                final url = Uri.parse("https://wa.me/1234567890");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),

            Divider(height: 1, thickness: 1),

            // Logout
            _buildMenuItem(
              icon: CupertinoIcons.square_arrow_left,
              title: "Logout",
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Get.back();
                _showLogoutDialog();
              },
            ),

            SizedBox(height: context.mediaQueryPadding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.grey.shade600,
              size: 22,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Call logout from AuthService
              Get.find<AuthService>().logout();
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
