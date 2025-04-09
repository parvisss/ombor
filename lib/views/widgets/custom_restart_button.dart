import 'package:flutter/material.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/utils/app_text_styles.dart';

class CustomRestartButton extends StatelessWidget {
  const CustomRestartButton({
    super.key,
    required this.onTap,
    this.child,
    this.color,
    this.height,
    this.width,
    this.message,
  });
  final VoidCallback? onTap;
  final Color? color;
  final double? width;
  final double? height;
  final Widget? child;
  final String? message;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Пусто"),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: color ?? AppColors.mainColor,
              borderRadius: BorderRadius.circular(20),
            ),
            height: height ?? 50,
            width: width ?? 100,
            child: Center(
              child:
                  child ??
                  Text(
                    message ?? "Обновить",
                    style: AppTextStyles.backgroundTextMedium,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
