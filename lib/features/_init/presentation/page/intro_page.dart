import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tree_expert/core/routes/app_routes.dart';
import 'package:tree_expert/core/styles/app_colors.dart';
import 'package:tree_expert/widgets/custom_buttons.dart';
import '../../data/model/intro_item_model.dart';
import '../controller/intro_controller.dart';

class IntroPage extends GetWidget<IntroController> {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simple Gradient Background
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: _getGradientForPage(controller.currentPage.value),
            ),
          )),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Page Content
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: (index) {
                      controller.currentPage.value = index;
                    },
                    itemCount: controller.introItems.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(
                        context,
                        controller.introItems[index],
                      );
                    },
                  ),
                ),

                // Bottom Section
                _buildBottomSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, IntroItemModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForPage(model.order),
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 50),

          // Title
          Text(
            model.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            model.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Dots Indicator
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.introItems.length,
                  (index) {
                final isActive = controller.currentPage.value == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          )),

          const SizedBox(height: 30),

          // Buttons
          Obx(() {
            final isLastPage = controller.currentPage.value ==
                controller.introItems.length - 1;

            return Row(
              children: [
                // Skip Button
                if (!isLastPage)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        controller.pageController.jumpToPage(
                          controller.introItems.length - 1,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 16),

                if (!isLastPage) const SizedBox(width: 16),

                // Next/Get Started Button
                Expanded(
                  flex: isLastPage ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        controller.markIntroAsSeen();
                        Get.offAllNamed(AppRoutes.mobileLogin);
                      } else {
                        controller.pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isLastPage ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  LinearGradient _getGradientForPage(int pageIndex) {
    final gradients = [
      // Green theme
      const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2E7D32),
          Color(0xFF1B5E20),
        ],
      ),
      // Blue theme
      const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1976D2),
          Color(0xFF0D47A1),
        ],
      ),
      // Teal theme
      const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF00897B),
          Color(0xFF00695C),
        ],
      ),
    ];

    return gradients[pageIndex % gradients.length];
  }

  IconData _getIconForPage(int order) {
    switch (order) {
      case 1:
        return Icons.forest;
      case 2:
        return Icons.eco;
      case 3:
        return Icons.park;
      default:
        return Icons.nature;
    }
  }
}