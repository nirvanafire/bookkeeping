import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:bookkeeping/providers/transaction_provider.dart';
import 'package:bookkeeping/models/transaction.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final expenseBreakdown = provider.getCategoryBreakdown(TransactionType.expense);
    final incomeBreakdown = provider.getCategoryBreakdown(TransactionType.income);

    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
      ),
      body: Column(
        children: [
          _buildTypeTabBar(),
          Expanded(
            child: _selectedIndex == 0
                ? _buildPieChartSection(expenseBreakdown, Colors.red.shade400)
                : _buildPieChartSection(incomeBreakdown, Colors.green.shade400),
          ),
          _buildLegend(provider),
        ],
      ),
    );
  }

  Widget _buildTypeTabBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _selectedIndex == 0 ? Colors.red.shade100 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '支出统计',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _selectedIndex == 0 ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _selectedIndex == 1 ? Colors.green.shade100 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '收入统计',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _selectedIndex == 1 ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection(
    Map<TransactionCategory, double> breakdown,
    Color primaryColor,
  ) {
    if (breakdown.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final percentage = total > 0 ? (data.value / total * 100) : 0;

                return PieChartSectionData(
                  value: data.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  radius: MediaQuery.of(context).size.width < 400 ? 60 : 80,
                  color: _getCategoryColor(index),
                  showTitle: true,
                );
              }).toList(),
              centerSpaceRadius: MediaQuery.of(context).size.width < 400 ? 25 : 35,
              sectionsSpace: 2,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '总计: ¥${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(TransactionProvider provider) {
    final breakdown = _selectedIndex == 0
        ? provider.getCategoryBreakdown(TransactionType.expense)
        : provider.getCategoryBreakdown(TransactionType.income);

    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '明细',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          ...entries.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final percentage = total > 0 ? (data.value / total * 100) : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(index),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    data.key.icon,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.key.displayName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '¥${data.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.yellow.shade600,
      Colors.green.shade400,
      Colors.cyan.shade400,
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
      Colors.brown.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.lime.shade600,
    ];
    return colors[index % colors.length];
  }
}
