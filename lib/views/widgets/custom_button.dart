import 'package:flutter/material.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_icons.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.color,
    this.child,
    required this.onTap,
    this.height,
    this.width,
  });
  final Color? color;
  final Widget? child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: color ?? AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        height: height ?? 60,
        width: width ?? double.infinity,
        child: Center(child: child ?? AppIcons.add),
      ),
    );
  }
}
