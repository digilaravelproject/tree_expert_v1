import 'dart:async';

import 'package:tree_expert/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_image_view.dart';

class ImageSlider extends StatefulWidget {
  final List<String> images;
  final double viewPort;
  final MainAxisAlignment indicatorAlignment;
  final EdgeInsets itemPadding;
  final bool autoScroll;
  final bool isIndicatorVisible;
  final double borderRadius;
  final bool enableNavigation;
  final IndicatorType indicatorType;

  const ImageSlider({
    super.key,
    required this.images,
    this.indicatorAlignment = MainAxisAlignment.center,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.viewPort = 0.9,
    this.isIndicatorVisible = true,
    this.enableNavigation = false,
    this.borderRadius = 16,
    this.autoScroll = true,
    this.indicatorType = IndicatorType.dot,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late PageController _pageController;
  int _currentPage = 1;
  Timer? _timer;

  List<String> get _loopImages => [
    widget.images.last,
    ...widget.images,
    widget.images.first,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: widget.viewPort,
    );

    if (widget.autoScroll) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < widget.images.length + 1) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _currentPage = 1;
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _loopImages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: widget.itemPadding,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (details) {
                    final width = MediaQuery.of(context).size.width;
                    final tapPosition = details.localPosition.dx;

                    if (tapPosition > width / 2) {
                      if (_currentPage < widget.images.length + 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    } else {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  },
                  child: CustomImageView(
                    url: _loopImages[index],
                    fit: BoxFit.fill,
                    errorBuilder: (ctx, p, q) =>
                        Center(child: Image.asset(AppAssets.imgAppLogo)),
                  ),
                ),
              ),
            );
          },
          onPageChanged: (index) {
            setState(() => _currentPage = index);

            if (index == _loopImages.length - 1) {
              Future.delayed(const Duration(milliseconds: 250), () {
                _pageController.jumpToPage(1);
              });
            } else if (index == 0) {
              Future.delayed(const Duration(milliseconds: 250), () {
                _pageController.jumpToPage(widget.images.length);
              });
            }
          },
        ),
        if (widget.isIndicatorVisible)
          Positioned(
            bottom: 12,
            right: 0,
            left: 0,
            child: _buildIndicator(context).marginOnly(top: 12),
          ),
      ],
    );
  }

  /// ------------------------------------------------------------
  /// INDICATOR BUILDER (Handles dot, rectangle, story indicators)
  /// ------------------------------------------------------------
  Widget _buildIndicator(BuildContext context) {
    switch (widget.indicatorType) {
    /// Small circular dots
      case IndicatorType.dot:
        return Row(
          mainAxisAlignment: widget.indicatorAlignment,
          children: List.generate(widget.images.length, (i) {
            bool active = (_currentPage == i + 1);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? context.theme.primaryColor
                    : context.theme.dividerColor,
                shape: BoxShape.circle,
              ),
            );
          }),
        );

    /// Rectangle pill indicators
      case IndicatorType.rectangle:
        return Row(
          mainAxisAlignment: widget.indicatorAlignment,
          children: List.generate(widget.images.length, (i) {
            bool active = (_currentPage == i + 1);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 10,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? context.theme.primaryColor
                    : context.theme.dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );

    /// Instagram-style story bar indicators
      case IndicatorType.story:
        return Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (i) {
            bool active = (_currentPage == i + 1);
            return Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: active
                      ? context.theme.primaryColor
                      : context.theme.dividerColor.withValues(alpha: 0.4),
                ),
              ),
            );
          }),
        ).marginSymmetric(horizontal: 12);
    }
  }
}

enum IndicatorType { story, rectangle, dot }
