import 'package:flutter/material.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_icons.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({
    super.key,
    this.color,
    this.child,
    required this.onTap,
  });
  final Color? color;
  final Widget? child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: color ?? AppColors.background,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.black, width: 1),
        ),
        height: 60,
        width: 60,
        child: AppIcons.add,
      ),
    );
  }
}
