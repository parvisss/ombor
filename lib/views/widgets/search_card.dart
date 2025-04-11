import 'package:flutter/material.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/utils/app_icons.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/home/widgets/balance_text_widget.dart'; // Yangi modelni import qilish

class SearchCard extends StatelessWidget {
  final CashFlowModel cashFlow;

  const SearchCard({super.key, required this.cashFlow});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(cashFlow.title, style: AppTextStyles.bodyLarge),
      subtitle: Text(cashFlow.comment ?? '', style: AppTextStyles.labelSmall),
      trailing: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(cashFlow.time, style: AppTextStyles.labelSmall),
              BalanceTextWidget(
                balance: cashFlow.amount,
                isIntallment: cashFlow.isInstallment == 1,
              ),
            ],
          ),
          AppIcons.arrowForqard,
        ],
      ),
    );
  }
}
