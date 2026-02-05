import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tree_expert/core/styles/app_decoration.dart';
import 'package:tree_expert/core/utils/app_assets.dart';
import 'package:tree_expert/features/_init/presentation/controller/init_controller.dart';
import 'package:tree_expert/widgets/custom_image_view.dart';
import 'package:tree_expert/core/constent/app_constants.dart';

class SplashPage extends GetWidget<InitController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Decorative background elements
          _buildBackgroundParticles(),

          // Main content centered
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section
                _buildLogoSection(context),

                const SizedBox(height: 40),

                // App name with gradient
                _buildAppName(context),

                const SizedBox(height: 12),

                // Main tagline
                _buildTagline(context),

                const SizedBox(height: 16),

                // Mission points
                _buildMissionPoints(context),

                const SizedBox(height: 40),

                // Loading indicator
                _buildLoadingIndicator(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 3),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: (value * 0.3).clamp(0.0, 0.3),
            child: CustomPaint(
              painter: _ParticlesPainter(value),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1800),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clampedValue,
          child: Opacity(
            opacity: clampedValue,
            child: child,
          ),
        );
      },
      child: Hero(
        tag: AppConstants.transitionLogo,
        child: SizedBox(
          width: Get.width * 0.55,
          height: Get.width * 0.55,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Rotating outer ring with pulse effect
              AnimatedBuilder(
                animation: controller.logoController,
                builder: (_, __) {
                  return Transform.rotate(
                    angle: controller.logoController.value * 2 * math.pi,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 2000),
                      curve: Curves.easeInOutCubic,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        final clampedValue = value.clamp(0.0, 1.0);
                        final pulseValue = (clampedValue * 0.15 *
                            (1 + 0.1 * (controller.logoController.value % 1)));
                        return Transform.scale(
                          scale: clampedValue + pulseValue,
                          child: Opacity(
                            opacity: clampedValue,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: Get.width * 0.52,
                        height: Get.width * 0.52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              context.theme.colorScheme.primary.withOpacity(0.3),
                              context.theme.colorScheme.secondary.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CustomImageView(
                          svgPath: AppAssets.bgCircleStroke,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Logo container with enhanced shadow
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  final clampedValue = value.clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: clampedValue,
                    child: Opacity(
                      opacity: clampedValue,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  height: Get.width * 0.44,
                  width: Get.width * 0.44,
                  padding: EdgeInsets.all(Get.width * 0.05),
                  decoration: AppDecorations.cardDecoration(context).copyWith(
                    borderRadius: BorderRadius.circular(Get.width * 0.22),
                    boxShadow: [
                      BoxShadow(
                        color: context.theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 5,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomImageView(
                    imagePath: AppAssets.imgAppLogo,
                    fit: BoxFit.cover,
                    radius: BorderRadius.circular(Get.width * 0.22),
                  ),
                ),
              ),

              // Animated leaves/particles around logo
              ...List.generate(6, (index) {
                return _buildFloatingLeaf(context, index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingLeaf(BuildContext context, int index) {
    final angle = (index * 60.0) * math.pi / 180;
    final radius = Get.width * 0.30;

    return AnimatedBuilder(
      animation: controller.logoController,
      builder: (context, child) {
        final offset = (controller.logoController.value + index * 0.15) % 1.0;
        final yOffset = offset * 20 - 10;

        return Positioned(
          left: Get.width * 0.275 + radius * math.cos(angle) - 8,
          top: Get.width * 0.275 + radius * math.sin(angle) - 8 + yOffset,
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 1500 + index * 200),
            curve: Curves.easeOut,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value * 0.6,
                child: Transform.scale(
                  scale: value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.theme.colorScheme.primary.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: context.theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: Transform.translate(
            offset: Offset(0, (1 - clampedValue) * 30),
            child: child,
          ),
        );
      },
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            context.theme.colorScheme.primary,
            context.theme.colorScheme.secondary,
          ],
        ).createShader(bounds),
        child: Text(
          "Tree Expert",
          style: context.textTheme.headlineLarge!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTagline(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: Transform.translate(
            offset: Offset(0, (1 - clampedValue) * 25),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Your Tree Conservation Partner ",
            style: context.textTheme.titleMedium!.copyWith(
              color: context.theme.primaryColorDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.bounceOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale.clamp(0.0, 1.0),
                child: const Text("🌳", style: TextStyle(fontSize: 20)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMissionPoints(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: Transform.translate(
            offset: Offset(0, (1 - clampedValue) * 20),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMissionPoint(context, "Survey", 0),
            _buildDivider(context),
            _buildMissionPoint(context, "Preserve", 300),
            _buildDivider(context),
            _buildMissionPoint(context, "Protect", 600),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOut,
      onEnd: controller.startNavigate,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedValue,
          child: child,
        );
      },
      child: Column(
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: context.theme.colorScheme.primary,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            "Loading your green journey...",
            style: context.textTheme.bodySmall!.copyWith(
              color: context.theme.primaryColorDark.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionPoint(BuildContext context, String text, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.5 + (clampedValue * 0.5),
          child: Opacity(
            opacity: clampedValue,
            child: Text(
              text,
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.theme.colorScheme.primary.withOpacity(0.5),
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double animationValue;

  _ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i * 0.15 + animationValue * 0.2)) % size.width;
      final y = (size.height * (i * 0.12 + animationValue * 0.15)) % size.height;
      final radius = 2 + (i % 3) * 1.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:tree_expert/core/styles/app_decoration.dart';
// import 'package:tree_expert/core/utils/app_assets.dart';
// import 'package:tree_expert/features/_init/presentation/controller/init_controller.dart';
// import 'package:tree_expert/widgets/custom_image_view.dart';
//
// import '../../../../core/utils/app_constants.dart';
//
// class SplashPage extends GetWidget<InitController> {
//   const SplashPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(AppAssets.imgBgScaffold),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Stack(
//           children: [
//             Hero(
//               tag: AppConstants.transitionLogo,
//               child: Align(
//                 alignment: Alignment.topCenter,
//                 child: SizedBox(
//                   width: Get.width * 0.52,
//                   height: Get.width * 0.52,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     clipBehavior: Clip.none,
//                     children: [
//                       AnimatedBuilder(
//                         animation: controller.logoController,
//                         builder: (_, __) {
//                           return Transform.rotate(
//                             angle: controller.logoController.value * 0.5 * 3.14,
//                             child: TweenAnimationBuilder<double>(
//                               duration: const Duration(seconds: 2),
//                               curve: Curves.easeInOutBack,
//                               tween: Tween(begin: 0.0, end: 1.0),
//                               builder: (context, value, child) {
//                                 return Transform.scale(
//                                   scale: value,
//                                   child: Opacity(
//                                     opacity: value.clamp(0.0, 1.0),
//                                     child: child,
//                                   ),
//                                 );
//                               },
//                               child: SizedBox.square(
//                                 dimension: Get.width * 0.48,
//                                 child: CustomImageView(
//                                   svgPath: AppAssets.bgCircleStroke,
//                                   fit: BoxFit.contain,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       TweenAnimationBuilder<double>(
//                         duration: const Duration(seconds: 2),
//                         curve: Curves.easeInOutBack,
//                         tween: Tween(begin: 0.0, end: 1.0),
//                         builder: (context, value, child) {
//                           return Transform.scale(
//                             scale: value,
//                             child: Opacity(
//                               opacity: value.clamp(0.0, 1.0),
//                               child: child,
//                             ),
//                           );
//                         },
//                         child: Container(
//                           height: Get.width * 0.44,
//                           width: Get.width * 0.44,
//                           padding: EdgeInsets.all(Get.width * 0.05),
//                           decoration: AppDecorations.cardDecoration(context)
//                               .copyWith(
//                                 borderRadius: BorderRadius.circular(
//                                   Get.width * 0.22,
//                                 ),
//                               ),
//                           child: CustomImageView(
//                             imagePath: AppAssets.imgAppLogo,
//                             fit: BoxFit.contain,
//                             radius: BorderRadius.circular(Get.width * 0.22),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ).marginOnly(top: Get.height * 0.25),
//             ),
//
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     /// MAIN TITLE ANIMATION
//                     TweenAnimationBuilder<double>(
//                       tween: Tween(begin: 0, end: 1),
//                       duration: const Duration(milliseconds: 900),
//                       curve: Curves.easeOut,
//                       builder: (context, value, child) {
//                         return Opacity(
//                           opacity: value,
//                           child: Transform.translate(
//                             offset: Offset(0, (1 - value) * 20),
//                             child: child,
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "Your Tree Conservation Partner 🌳",
//                         style: context.textTheme.headlineSmall!.copyWith(
//                           color: context.theme.primaryColorDark,
//
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 6),
//
//                     /// TAGLINE ANIMATION
//                     TweenAnimationBuilder<double>(
//                       tween: Tween(begin: 0, end: 1),
//                       duration: const Duration(milliseconds: 1200),
//                       curve: Curves.easeOut,
//                       builder: (context, value, child) {
//                         return Opacity(
//                           opacity: value,
//                           child: Transform.translate(
//                             offset: Offset(0, (1 - value) * 15),
//                             child: child,
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "Survey ● Preserve ● Protect",
//                         style: context.textTheme.bodySmall!.copyWith(
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 32),
//
//                     /// BOUNCING PROGRESS INDICATOR
//                     TweenAnimationBuilder<double>(
//                       tween: Tween(begin: 0.8, end: 1.3),
//                       duration: const Duration(milliseconds: 1000),
//                       curve: Curves.easeInOut,
//                       onEnd: controller.startNavigate,
//                       builder: (context, scale, child) {
//                         return Transform.scale(scale: scale, child: child);
//                       },
//                       child: LoadingAnimationWidget.fourRotatingDots(
//                         color: context.theme.colorScheme.primary,
//                         size: 30,
//                       ),
//                     ),
//
//                     SizedBox(height: context.mediaQueryPadding.bottom + 35),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
