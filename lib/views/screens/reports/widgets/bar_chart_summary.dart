import 'package:flutter/material.dart';

class BarChartSummary extends StatelessWidget {
  final List<DateTime> dates;
  final List<double> incomes;
  final List<double> expenses;

  const BarChartSummary({
    super.key,
    required this.dates,
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(dates.length, (index) {
        final date = dates[index];
        final income = incomes[index];
        final expense = expenses[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Text(
            '${date.day}/${date.month} - Kirim: ${income.toStringAsFixed(2)} so‘m, Chiqim: ${expense.toStringAsFixed(2)} so‘m',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }),
    );
  }
}
