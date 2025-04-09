import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineGraphWidget extends StatelessWidget {
  final List<DateTime> dates;
  final List<double> incomes;
  final List<double> expenses;

  const LineGraphWidget({
    super.key,
    required this.dates,
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Kirim/Chiqim Vaqt bo‘yicha",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < dates.length) {
                          final date = dates[index];
                          return Text(
                            "${date.day}/${date.month}",
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      incomes.length,
                      (i) => FlSpot(i.toDouble(), incomes[i]),
                    ),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      expenses.length,
                      (i) => FlSpot(i.toDouble(), expenses[i]),
                    ),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
