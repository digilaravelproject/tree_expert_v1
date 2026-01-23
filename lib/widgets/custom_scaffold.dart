import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_snack_bar.dart';

class CustomScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? extendBody;
  final bool extendBodyBehindAppBar;
  final bool enableDoubleTapExit;

  const CustomScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.extendBody,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.enableDoubleTapExit = false,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  DateTime? _lastPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.enableDoubleTapExit,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (widget.enableDoubleTapExit && !didPop) {
          final now = DateTime.now();
          final bool shouldShowPrompt =
              _lastPressed == null ||
              now.difference(_lastPressed!) > const Duration(seconds: 2);
          if (shouldShowPrompt) {
            _lastPressed = now;
            CustomSnackBar.showInfo(message: "Press back again to exit");
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: widget.appBar,
        drawer: widget.drawer,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: widget.bottomNavigationBar,
        extendBody: widget.extendBody ?? true,
        body: widget.body,
      ),
    );
  }
}
