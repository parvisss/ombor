import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ombor/utils/app_text_styles.dart'; // O'zingizning stil faylingizga moslashtiring

class BalanceTextWidget extends StatelessWidget {
  final num balance;
  final bool? isIntallment;

  // Constructor orqali balance qiymatini qabul qilamiz
  const BalanceTextWidget({
    super.key,
    required this.balance,
    this.isIntallment,
  });

  // Formatlash uchun yordamchi funksiya
  String _formatBalance(num balance) {
    final numberFormat = NumberFormat(
      "#,##0",
    ); // 10 000 000 kabi formatlash uchun
    if (balance >= 1_000_000_000) {
      return "${numberFormat.format(balance / 1_000_000_000)} mlrd";
    } else if (balance >= 10_000_000) {
      return "${numberFormat.format(balance / 1_000_000)} mln";
    } else {
      return numberFormat.format(balance).replaceAll(',', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Balance formatlash
    String formattedBalance = _formatBalance(balance);

    return Text(
      "${isIntallment != null && !isIntallment! && balance >= 0 ? '+' : ''} $formattedBalance Uzs",
      style:
          isIntallment != null && isIntallment!
              ? AppTextStyles
                  .bodyLarge // Nasiya to'lovlari uchun alohida stil
              : balance > 0
              ? AppTextStyles.bodyLargePositive
              : balance < 0
              ? AppTextStyles.bodyLargeNegative
              : AppTextStyles.bodyLarge,
    );
  }
}
