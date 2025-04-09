import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ombor/models/cash_flow_model.dart';

class PieChartWidget extends StatelessWidget {
  final List<CashFlowModel> cashFlows;
  final String title;

  const PieChartWidget({
    super.key,
    required this.cashFlows,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Kategoriyalar bo'yicha summalarni hisoblash
    final Map<String, double> categoryTotals = {};

    for (var cashFlow in cashFlows) {
      // Agar kategoriya allaqachon mavjud bo'lsa, miqdorni qo'shish
      categoryTotals[cashFlow.title] =
          (categoryTotals[cashFlow.title] ?? 0.0) + cashFlow.amount.toDouble();
    }

    // Umumiy summa
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    // Kategoriyalar va miqdorlar ro'yxatini olish
    final entries = categoryTotals.entries.toList();
    if (cashFlows.isNotEmpty) {
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
                          showTitle:
                              double.parse(percentage) >=
                              10.0, // Show title only if percentage >= 25
                          title: '$percentage%', // Foizni segmentda ko'rsatish
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend (Chiziqli ro'yxat)
            _buildLegend(entries, total),
          ],
        ),
      );
    }
    return SizedBox();
  }

  /// Ranglarni avtomatik generatsiya qilish funksiyasi.
  Color _getColor(int index) {
    final double hue = (index * 37) % 360;
    return HSVColor.fromAHSV(1.0, hue, 0.75, 0.90).toColor();
  }

  /// Legend uchun widget yaratiladi.
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
