import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../core/styles/app_colors.dart';
import '../core/utils/app_assets.dart';

class CustomImageView extends StatelessWidget {
  ///[url] is required parameter for fetching network image
  final String? url;

  ///[imagePath] is required parameter for showing png,jpg,etc image
  final String? imagePath;

  ///[svgPath] is required parameter for showing svg image
  final String? svgPath;

  ///[svgString] is required parameter for showing svg image in string value
  final String? svgString;

  ///[file] is required parameter for fetching image file
  final File? file;

  /// The height of the image.
  final double? height;

  /// The width of the image.
  final double? width;

  /// The color to filter the image with.
  final Color? color;

  /// The color to filter the [SVG_ASSETS] with.
  final ColorFilter? colorFilter;

  /// A widget to display when the image fails to load.
  final Widget Function(BuildContext, String, Object)? errorWidget;

  /// A builder function that creates a widget when the image fails to load.
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  /// A builder function that creates a widget when the image have some decorations.
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;

  /// How the image should be inscribed into the space allocated during layout.
  final BoxFit? fit;

  /// A placeholder widget to display while the image is being loaded.
  final Widget Function(BuildContext, String)? placeHolder;

  /// The alignment of the image within its frame.
  final Alignment? alignment;

  /// The callback that is called when the image is tapped.
  final VoidCallback? onTap;

  /// The margin around the image.
  final EdgeInsetsGeometry? margin;

  /// The border radius of the image.
  final BorderRadiusGeometry? radius;

  /// The border of the image.
  final BoxBorder? border;

  /// The blend mode applied to the image.
  final BlendMode? blendMode;

  final bool enableFv;

  ///a [CustomImageView] it can be used for showing any type of images
  /// it will shows the placeholder image if image is not found on network image
  const CustomImageView({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.svgString,
    this.color,
    this.colorFilter,
    this.errorWidget,
    this.errorBuilder,
    this.imageBuilder,
    this.fit,
    this.placeHolder,
    this.alignment,
    this.onTap,
    this.margin,
    this.radius,
    this.border,
    this.blendMode,
    this.enableFv = false,
  });

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWidget(context))
        : _buildWidget(context);
  }

  Widget _buildWidget(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap:
            onTap ??
            () {
              if (url != null && url!.isNotEmpty && enableFv) {
                Get.to(() => ImageFvScreen(imageUrl: url!));
              } else if (file != null && file!.path.isNotEmpty && enableFv) {
                Get.to(() => ImageFvScreen(imageFile: file));
              }
            },
        child: _buildCircleImage(context),
      ),
    );
  }

  ///build the image with border radius
  _buildCircleImage(BuildContext context) {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius!,
        child: _buildImageWithBorder(context),
      );
    } else {
      return _buildImageWithBorder(context);
    }
  }

  ///build the image with border and border radius style
  _buildImageWithBorder(BuildContext context) {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: _buildImageView(context),
      );
    } else {
      return _buildImageView(context);
    }
  }

  Widget _buildImageView(BuildContext context) {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: SvgPicture.asset(
          svgPath!,
          alignment: alignment ?? Alignment.center,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: color != null
              ? ColorFilter.mode(color!, blendMode ?? BlendMode.srcIn)
              : colorFilter,
        ),
      );
    } else if (svgString != null && svgString!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: SvgPicture.string(
          svgString!,
          alignment: alignment ?? Alignment.center,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: color != null
              ? ColorFilter.mode(color!, blendMode ?? BlendMode.srcIn)
              : colorFilter,
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return Image.file(
        file!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        alignment: alignment ?? Alignment.center,
      );
    }
    /*else if (xFile != null && xFile!.path.isNotEmpty) {
      return Image.file(
        File(xFile!.path),
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        alignment: alignment ?? Alignment.center,
      );
    } */
    else if (url != null && url!.isNotEmpty) {
      return CachedNetworkImage(
        height: height,
        width: width,
        fit: fit,
        imageUrl: url!,
        imageBuilder:
            imageBuilder ??
            (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter: color != null
                      ? ColorFilter.mode(color!, BlendMode.color)
                      : colorFilter,
                ),
              ),
            ),
        placeholder:
            placeHolder ??
            (context, url) => SizedBox(
              height: 30,
              width: 30,
              child: LinearProgressIndicator(
                color: Colors.grey.shade200,
                backgroundColor: Colors.grey.shade100,
              ),
            ),
        alignment: alignment ?? Alignment.center,
        errorWidget:
            errorWidget ??
            (_, __, ___) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: context.isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                child: Center(child: Icon(Icons.image_not_supported_rounded)),
              );
            },
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.asset(
        imagePath!,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        color: color,
        errorBuilder: errorBuilder,
        alignment: alignment ?? Alignment.center,
      );
    }
    return const SizedBox();
  }
}

class ImageFvScreen extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;

  const ImageFvScreen({super.key, this.imageUrl, this.imageFile});

  @override
  State<ImageFvScreen> createState() => _ImageFvScreenState();
}

class _ImageFvScreenState extends State<ImageFvScreen> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _tapDownDetails;

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      final position = _tapDownDetails!.localPosition;

      _controller.value = Matrix4.identity()
        ..translateByDouble(-position.dx * 2, -position.dy * 2, 0.0, 1.0)
        ..scaleByDouble(3.0, 3.0, 1.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: Get.back,
          style: IconButton.styleFrom(side: BorderSide.none),
          icon: Icon(AppAssets.backArrow, color: Colors.white),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onDoubleTapDown: (details) => _tapDownDetails = details,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: 1.0,
            maxScale: 5.0,
            panEnabled: true,
            scaleEnabled: true,
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return Image.network(widget.imageUrl!, fit: BoxFit.contain);
    } else if (widget.imageFile != null) {
      return Image.file(widget.imageFile!, fit: BoxFit.contain);
    }
    return const SizedBox.shrink();
  }
}
