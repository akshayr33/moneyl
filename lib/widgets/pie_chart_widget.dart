import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildSections(),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
    ];

    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final radius = entry.value / total * 30 + 15;
      final color = colors[data.keys.toList().indexOf(entry.key) % colors.length];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '$percentage%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
    ];

    return data.entries.map((entry) {
      final color = colors[data.keys.toList().indexOf(entry.key) % colors.length];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(entry.key),
            ),
            Text(
              '\$${entry.value.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }
}