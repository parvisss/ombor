import 'package:flutter/widgets.dart';
import 'package:ombor/utils/app_colors.dart';

class AppTextStyles {
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const TextStyle bodyLargeNegative = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w400,
    color: AppColors.negative,
  );
  static const TextStyle bodyLargePositive = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w400,
    color: AppColors.positive,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const TextStyle backgroundTextMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.background,
  );
}
