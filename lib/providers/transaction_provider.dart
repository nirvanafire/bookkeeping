import 'package:flutter/foundation.dart';
import 'package:bookkeeping/models/transaction.dart';
import 'package:bookkeeping/database/database.dart';

class TransactionProvider with ChangeNotifier {
  final AppDatabase database;
  List<Transaction> _transactions = [];
  DateTime? _selectedMonth = DateTime.now();
  TransactionType? _filterType;

  TransactionProvider({required this.database});

  List<Transaction> get transactions {
    if (_selectedMonth == null) {
      return _transactions;
    }
    return _transactions.where((t) {
      return t.dateTime.year == _selectedMonth!.year &&
          t.dateTime.month == _selectedMonth!.month;
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  DateTime? get selectedMonth => _selectedMonth;
  TransactionType? get filterType => _filterType;

  double get totalIncome {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    // 先显示所有数据，避免空状态
    _selectedMonth = null;
    notifyListeners();

    final allTransactions = await database.select(database.transactionData).get();
    _transactions = allTransactions
        .map((data) => Transaction.fromDrift(data))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // 恢复当前月份筛选
    _selectedMonth = DateTime.now();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await database.into(database.transactionData).insert(transaction.toCompanion());
    await loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await database.update(database.transactionData).replace(transaction.toCompanion());
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await (database.delete(database.transactionData)
          ..where((t) => t.id.equals(id)))
        .go();
    await loadTransactions();
  }

  void setSelectedMonth(DateTime? month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setFilterType(TransactionType? type) {
    _filterType = type;
    notifyListeners();
  }

  void clearFilters() {
    _selectedMonth = null;
    _filterType = null;
    notifyListeners();
  }

  // Get transactions grouped by date
  Map<DateTime, List<Transaction>> getTransactionsGroupedByDate() {
    final grouped = <DateTime, List<Transaction>>{};
    for (final transaction in transactions) {
      final date = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );
      grouped.putIfAbsent(date, () => []).add(transaction);
    }
    return grouped;
  }

  // Get category breakdown for pie chart
  Map<TransactionCategory, double> getCategoryBreakdown(TransactionType type) {
    final filtered = transactions.where((t) => t.type == type);
    final breakdown = <TransactionCategory, double>{};
    for (final t in filtered) {
      breakdown.update(t.category, (value) => value + t.amount,
          ifAbsent: () => t.amount);
    }
    return breakdown;
  }
}
