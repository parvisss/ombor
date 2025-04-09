import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ombor/models/cash_flow_model.dart';
import 'package:ombor/utils/app_colors.dart';

class PieCahrtOverall extends StatelessWidget {
  final List<CashFlowModel> cashFlows;
  final String title;

  const PieCahrtOverall({
    super.key,
    required this.cashFlows,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var cashFlow in cashFlows) {
      if (cashFlow.amount > 0) {
        totalIncome += cashFlow.amount;
      } else {
        totalExpense += cashFlow.amount.abs(); // Musbat qiymat qilib qo‘shamiz
      }
    }

    final total = totalIncome + totalExpense;

    final List<MapEntry<String, double>> entries = [
      MapEntry('Kirim', totalIncome),
      MapEntry('Chiqim', totalExpense),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections:
                    entries.map((e) {
                      final percentage = ((e.value / total) * 100)
                          .toStringAsFixed(1);
                      return PieChartSectionData(
                        value: e.value,
                        color: _getColor(entries.indexOf(e)),
                        radius: 80,
                        showTitle: true,
                        title: '$percentage%',
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(entries, total),
        ],
      ),
    );
  }

  Color _getColor(int index) {
    final colors = [AppColors.positive, AppColors.negative];
    return colors[index % colors.length];
  }

  Widget _buildLegend(List<MapEntry<String, double>> entries, double total) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          entries.map((e) {
            final percentage = ((e.value / total) * 100).toStringAsFixed(1);
            return _LegendItem(
              color: _getColor(entries.indexOf(e)),
              label: '${e.key} - ${e.value.toStringAsFixed(2)} ($percentage%)',
            );
          }).toList(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.rectangle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
