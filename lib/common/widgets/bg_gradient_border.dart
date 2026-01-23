import 'package:tree_expert/core/styles/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BgGradientBorder extends StatelessWidget {
  final Widget child;

  const BgGradientBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: AppColors.borderGradient),
      ),
      padding: EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.theme.colorScheme.surface,
        ),
        child: child,
      ),
    );
  }
}
