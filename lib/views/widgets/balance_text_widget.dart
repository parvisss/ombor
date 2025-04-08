import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ombor/utils/app_text_styles.dart'; // O'zingizning stil faylingizga moslashtiring

class BalanceTextWidget extends StatelessWidget {
  final num balance;

  // Constructor orqali balance qiymatini qabul qilamiz
  const BalanceTextWidget({super.key, required this.balance});

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
      "${balance > 0 ? "+" : ''} $formattedBalance Uzs",
      style:
          balance > 0
              ? AppTextStyles
                  .bodyLargePositive // Musbat balance uchun stil
              : balance < 0
              ? AppTextStyles
                  .bodyLargeNegative // Manfiy balance uchun stil
              : AppTextStyles.bodyLarge, // Nol balance uchun stil
    );
  }
}
