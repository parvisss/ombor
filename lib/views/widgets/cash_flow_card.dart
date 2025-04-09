import 'package:flutter/material.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/utils/app_text_styles.dart';
import 'package:ombor/views/screens/home/widgets/balance_text_widget.dart'; // Yangi modelni import qilish

class CashFlowCard extends StatelessWidget {
  final CashFlowModel cashFlow;

  const CashFlowCard({super.key, required this.cashFlow});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(cashFlow.title, style: AppTextStyles.bodyLarge),
      subtitle: Text(cashFlow.comment ?? '', style: AppTextStyles.labelSmall),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(cashFlow.time, style: AppTextStyles.labelSmall),
          BalanceTextWidget(balance: cashFlow.amount),
        ],
      ),
    );
  }
}
