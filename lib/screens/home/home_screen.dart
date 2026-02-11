import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:bookkeeping/providers/transaction_provider.dart';
import 'package:bookkeeping/models/transaction.dart';
import 'package:bookkeeping/screens/add/add_transaction_screen.dart';
import 'package:bookkeeping/widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(provider),
            _buildSummaryCards(provider),
            Expanded(
              child: provider.transactions.isEmpty
                  ? _buildEmptyState()
                  : _buildTransactionList(provider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = context.read<TransactionProvider>();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          if (mounted) {
            provider.loadTransactions();
          }
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            provider.selectedMonth != null
                ? DateFormat('yyyy年M月').format(provider.selectedMonth!)
                : '全部',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.grey[600],
            size: 28,
          ),
          const Spacer(),
          _buildMonthSelector(provider),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(TransactionProvider provider) {
    return PopupMenuButton<DateTime>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '选择月份',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
      onSelected: (month) {
        provider.setSelectedMonth(month);
      },
      itemBuilder: (context) {
        final now = DateTime.now();
        final months = List.generate(12, (index) {
          return DateTime(now.year, now.month - index, 1);
        }).reversed.toList();

        return [
          PopupMenuItem(
            enabled: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: const Text(
                '选择月份',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: DateTime(0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    provider.selectedMonth == null ? Icons.check : Icons.calendar_today,
                    size: 18,
                    color: provider.selectedMonth == null ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '全部',
                    style: TextStyle(
                      color: provider.selectedMonth == null ? Colors.blue : Colors.black87,
                      fontWeight: provider.selectedMonth == null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...months.map((month) {
            final isSelected = provider.selectedMonth?.year == month.year &&
                provider.selectedMonth?.month == month.month;
            return PopupMenuItem(
              value: month,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check : Icons.calendar_today,
                      size: 18,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy年M月').format(month),
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ];
      },
    );
  }

  Widget _buildSummaryCards(TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              label: '收入',
              amount: provider.totalIncome,
              gradientColors: [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
              icon: Icons.trending_up,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              label: '支出',
              amount: provider.totalExpense,
              gradientColors: [const Color(0xFFE91E63), const Color(0xFFC2185B)],
              icon: Icons.trending_down,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              label: '结余',
              amount: provider.balance,
              gradientColors: [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
              icon: Icons.account_balance_wallet,
              isBalance: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required List<Color> gradientColors,
    required IconData icon,
    bool isBalance = false,
  }) {
    final displayAmount = amount < 0 ? -amount : amount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Text(
                isBalance && amount < 0 ? '超支' : label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '¥${displayAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角添加第一笔记录',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    final grouped = provider.getTransactionsGroupedByDate();
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayTransactions = grouped[date]!;
        final dayTotal = dayTransactions.fold(
          0.0,
          (sum, t) =>
              sum +
              (t.type == TransactionType.income ? t.amount : -t.amount),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    DateFormat('M月d日').format(date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getWeekday(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: dayTotal >= 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${dayTotal >= 0 ? '+' : ''}${dayTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: dayTotal >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...dayTransactions.map((transaction) {
              return TransactionCard(
                transaction: transaction,
                onDelete: () {
                  provider.deleteTransaction(transaction.id!);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[date.weekday % 7];
  }
}
