import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackBarType { success, warning, error, info }

enum SnackBarPosition { top, bottom }

class CustomSnackBar {
  static void show({
    required String message,
    SnackBarType type = SnackBarType.success,
    SnackBarPosition position = SnackBarPosition.bottom,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    if (position == SnackBarPosition.bottom) {
      _showBottom(
        message: message,
        type: type,
        duration: duration,
        onTap: onTap,
        context: context,
      );
    } else {
      _showTop(message: message, type: type, duration: duration, onTap: onTap);
    }
  }

  static void _showBottom({
    required String message,
    required SnackBarType type,
    required Duration duration,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    final ctx = context ?? Get.context ?? Get.overlayContext;
    if (ctx == null) return;

    final snackBar = SnackBar(
      content: _SnackBarContent(message: message, type: type, onTap: onTap),
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    );

    final messenger = ScaffoldMessenger.maybeOf(ctx);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void _showTop({
    required String message,
    required SnackBarType type,
    required Duration duration,
    VoidCallback? onTap,
  }) {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    final overlay = Overlay.of(ctx);

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 60,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _SnackBarContent(message: message, type: type, onTap: onTap),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();
    });
  }

  static void showSuccess({
    required String message,
    SnackBarPosition position = SnackBarPosition.bottom,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    show(
      message: message,
      type: SnackBarType.success,
      position: position,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }

  static void showWarning({
    required String message,
    SnackBarPosition position = SnackBarPosition.bottom,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    show(
      message: message,
      type: SnackBarType.warning,
      position: position,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }

  static void showError({
    required String message,
    SnackBarPosition position = SnackBarPosition.top,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    show(
      message: message,
      type: SnackBarType.error,
      position: position,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }

  static void showInfo({
    required String message,
    SnackBarPosition position = SnackBarPosition.bottom,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    show(
      message: message,
      type: SnackBarType.info,
      position: position,
      duration: duration,
      onTap: onTap,
      context: context,
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final SnackBarType type;
  final VoidCallback? onTap;

  const _SnackBarContent({
    required this.message,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_getIcon(), color: _getIconColor(), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              onTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getCloseButtonColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.close, color: _getTextColor(), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFF0FDF4);
      case SnackBarType.warning:
        return const Color(0xFFFFFBEB);
      case SnackBarType.error:
        return const Color(0xFFFEF2F2);
      case SnackBarType.info:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFBBF7D0);
      case SnackBarType.warning:
        return const Color(0xFFFDE68A);
      case SnackBarType.error:
        return const Color(0xFFFECACA);
      case SnackBarType.info:
        return const Color(0xFFBFDBFE);
    }
  }

  Color _getShadowColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF22C55E).withValues(alpha: 0.15);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.15);
      case SnackBarType.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.15);
      case SnackBarType.info:
        return const Color(0xFF3B82F6).withValues(alpha: 0.15);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF166534);
      case SnackBarType.warning:
        return const Color(0xFF92400E);
      case SnackBarType.error:
        return const Color(0xFF991B1B);
      case SnackBarType.info:
        return const Color(0xFF1E40AF);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF22C55E);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B);
      case SnackBarType.error:
        return const Color(0xFFEF4444);
      case SnackBarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFFDCFCE7);
      case SnackBarType.warning:
        return const Color(0xFFFEF3C7);
      case SnackBarType.error:
        return const Color(0xFFFEE2E2);
      case SnackBarType.info:
        return const Color(0xFFDBEAFE);
    }
  }

  Color _getCloseButtonColor() {
    return _getTextColor().withValues(alpha: 0.1);
  }

  IconData _getIcon() {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.info:
        return Icons.info;
    }
  }
}
