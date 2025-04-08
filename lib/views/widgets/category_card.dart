import 'package:flutter/material.dart';
import 'package:ombor/models/category_model.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/widgets/balance_text_widget.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(category.title, style: AppTextStyles.bodyLarge),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(category.time, style: AppTextStyles.labelSmall),
          BalanceTextWidget(balance: category.balance),
        ],
      ),
    );
  }
}
