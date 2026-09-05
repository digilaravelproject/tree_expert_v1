import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';
import 'package:tree_expert/widgets/app_image_slider.dart';
import 'package:tree_expert/widgets/custom_buttons.dart';
import 'package:tree_expert/widgets/custom_image_view.dart';
import 'package:shimmer/shimmer.dart';


import '../../../auth/services/auth_service.dart';
import '../../../profile/presentation/controller/profile_controller.dart';
import '../widgets/project_card_shimmer.dart';
import '../widgets/api_project_card.dart';
import '../controller/home_controller.dart';
import '../widgets/profile_bottom_sheet.dart';

class HomePage extends GetWidget<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: controller.refreshProjects,
        color: context.theme.primaryColor,
        child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 80,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: false,
            elevation: 0,
            titleSpacing: 16,
            title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                   children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        color: context.theme.primaryColor,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          controller.currentAddress.isEmpty ? "Fetching..." : controller.currentAddress,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20),
                   ]
                ),
              ],
            )),
            actions: [


              Container(
                width: 45,
                height: 45,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Material(
                    color: Colors.grey.shade200,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.profile);
                      },
                      child: Obx(() {
                        // Get profile controller
                        final profileController = Get.find<ProfileController>();
                        final profileImageUrl = profileController.userProfile.value?.profileImage;

                        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
                          return CustomImageView(
                            url: profileImageUrl,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            onTap: () {
                              // Override default behavior - do nothing or navigate to profile
                              Get.toNamed(AppRoutes.profile);
                            },
                            enableFv: false, // Disable full view
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade500,
                                size: 28,
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey.shade500,
                              size: 28,
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                ),
              ),


              // Notification Bell
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.grey.shade100,
              //     shape: BoxShape.circle,
              //   ),
              //   child: IconButton(
              //     onPressed: () {
              //       Get.toNamed(AppRoutes.notification);
              //     },
              //     icon: Icon(
              //       CupertinoIcons.bell,
              //       color: Colors.grey.shade700,
              //       size: 22,
              //     ),
              //   ),
              // ),
              // SizedBox(width: 12),
              // Profile Image
/*
               Padding(
                 padding: const EdgeInsets.all(16.0),
                      child: Obx(() {
                        final profileController = Get.find<ProfileController>();
                        final profileImageUrl = profileController.userProfile.value?.profileImage;

                        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
                          return ClipOval(
                            child: CustomImageView(
                              url: profileImageUrl,
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey.shade500,
                                  size: 28,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.grey.shade500,
                              size: 28,
                            ),
                          );
                        }
                      }),

               ),*/




              /*Container(
                width: 45,
                height: 45,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
        child: Material(
          color: Colors.grey.shade200,
          child: InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.profile);
            },
            child:
           *//* Center(
              child: SizedBox(
                width: 56, // Circle ka size
                height: 56,
                child: ClipOval(
                  child: Image.network(
                    "",// Yaha aapka network image URL
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Agar image load na ho to icon dikhaye
                      return Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade500,
                          size: 28,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),*//*

            Obx(() {
              // Get profile controller
              final profileController = Get.find<ProfileController>();
              final profileImageUrl = profileController.userProfile.value?.profileImage;

              if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
                return CustomImageView(
                  url: profileImageUrl,
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade500,
                      size: 28,
                    ),
                  ),
                );
              } else {
                return Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.person,
                    color: Colors.grey.shade500,
                    size: 28,
                  ),
                );
              }
            }),
          ),
        ),
      ),

      // ClipRRect(
                //   borderRadius: BorderRadius.circular(25),
                //   child: Material(
                //     color: Colors.grey.shade200,
                //     child: InkWell(
                //       onTap: () {
                //          Get.toNamed(AppRoutes.profile);
                //       },
                //       child: Center(
                //         child: Icon(Icons.person, color: Colors.grey.shade500, size: 28),
                //       ),
                //     ),
                //   ),
                // ),
              ),*/
            ],
          ),


          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),

                // Greeting Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                         "${controller.greetingMessage},",
                         style: TextStyle(
                           fontSize: 16,
                           color: Colors.grey.shade600,
                         ),
                      ),
                      Text(
                        controller.userName.value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  )),
                ),

                SizedBox(height: 20),

                // Simple Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.search, arguments: {'projects': controller.projectsList});
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: context.theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            color: context.theme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Search projects...",
                              style: TextStyle(
                                color: context.theme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                  // Stats Row with Shimmer
                  Obx(() {
                    if (controller.isLoadingStats.value) {
                      // Show shimmer while loading
                      return SizedBox(
                        height: 125,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildStatCardShimmer(),
                            SizedBox(width: 12),
                            _buildStatCardShimmer(),
                            SizedBox(width: 12),
                            _buildStatCardShimmer(),
                          ],
                        ),
                      );
                    }
                    
                    // Show actual stats
                    return SizedBox(
                      height: 125,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildStatCard(
                            context,
                            icon: CupertinoIcons.tree,
                            title: "Trees",
                            value: "${controller.treeCount.value}",
                            color: Colors.green,
                          ),
                          SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            icon: CupertinoIcons.folder_fill,
                            title: "Projects",
                            value: "${controller.projectCount.value}",
                            color: Colors.blue,
                          ),
                          SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            icon: CupertinoIcons.location_fill,
                            title: "Districts",
                            value: "${controller.districtCount.value}",
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    );
                  }),

                SizedBox(height: 20),

                SizedBox(height: 12),

                // Projects Header & Filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "My Projects",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Obx(() => Text(
                                  "${controller.filteredProjects.length}", // Filtered count
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: context.theme.primaryColor,
                                  ),
                                )),
                              ),
                            ],
                          ),
                          Obx(() => !Get.find<AuthService>().isCompanyLogin.value 
                            ? Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.theme.primaryColor,
                                      context.theme.primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.theme.primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Get.toNamed(AppRoutes.addProjects);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add_circle,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Add Project",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink()
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                  ],
                ),

                SizedBox(height: 16),

                // Projects List
                Obx(() {
                  if (controller.isLoadingProjects.value) {
                    // Show shimmer loading
                    return ListView.builder(
                      itemCount: 3,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ProjectCardShimmer();
                      },
                    );
                  } else if (controller.filteredProjects.isEmpty) {
                    // Show empty state
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No projects found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Show project list
                    return ListView.builder(
                      itemCount: controller.filteredProjects.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: ApiProjectCard(
                            project: controller.filteredProjects[index],
                          ),
                        );
                      },
                    );
                  }
                }),

                SizedBox(height: 100),
              ],
            ),
          ),
        ],
        ),
      ),
      /*floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)], // Premium Green Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
               Get.toNamed(AppRoutes.geoTagCamera);
            },
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.camera_viewfinder, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    "Geo Tag Camera",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),*/
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color color,
      }) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: context.theme.hintColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? context.theme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? context.theme.primaryColor : Colors.grey.shade300,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: context.theme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildStatCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 140,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: 40,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}