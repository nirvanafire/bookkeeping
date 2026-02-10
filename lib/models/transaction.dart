import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as d;
import 'package:bookkeeping/database/database.dart';

enum TransactionType { expense, income }

enum TransactionCategory {
  // Expense categories
  food,
  transport,
  shopping,
  entertainment,
  utilities,
  healthcare,
  education,
  otherExpense,
  // Income categories
  salary,
  bonus,
  investment,
  otherIncome,
}

extension TransactionCategoryExtension on TransactionCategory {
  bool get isExpense {
    return this == TransactionCategory.food ||
        this == TransactionCategory.transport ||
        this == TransactionCategory.shopping ||
        this == TransactionCategory.entertainment ||
        this == TransactionCategory.utilities ||
        this == TransactionCategory.healthcare ||
        this == TransactionCategory.education ||
        this == TransactionCategory.otherExpense;
  }

  String get displayName {
    switch (this) {
      case TransactionCategory.food:
        return '餐饮';
      case TransactionCategory.transport:
        return '交通';
      case TransactionCategory.shopping:
        return '购物';
      case TransactionCategory.entertainment:
        return '娱乐';
      case TransactionCategory.utilities:
        return '生活';
      case TransactionCategory.healthcare:
        return '医疗';
      case TransactionCategory.education:
        return '教育';
      case TransactionCategory.otherExpense:
        return '其他支出';
      case TransactionCategory.salary:
        return '工资';
      case TransactionCategory.bonus:
        return '奖金';
      case TransactionCategory.investment:
        return '理财';
      case TransactionCategory.otherIncome:
        return '其他收入';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.transport:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.utilities:
        return Icons.home;
      case TransactionCategory.healthcare:
        return Icons.local_hospital;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.otherExpense:
        return Icons.more_horiz;
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.bonus:
        return Icons.card_giftcard;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.otherIncome:
        return Icons.attach_money;
    }
  }
}

class Transaction {
  final int? id;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final String note;
  final DateTime dateTime;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.dateTime,
  });

  TransactionDataCompanion toCompanion() {
    return TransactionDataCompanion(
      id: id != null ? d.Value(id!) : d.Value.absent(),
      amount: d.Value(amount),
      type: d.Value(type.index == 0 ? 'expense' : 'income'),
      category: d.Value(category.index),
      note: d.Value(note),
      createdAt: d.Value(dateTime),
    );
  }

  factory Transaction.fromDrift(TransactionDataData data) {
    return Transaction(
      id: data.id,
      amount: data.amount,
      type: data.type == 'expense'
          ? TransactionType.expense
          : TransactionType.income,
      category: TransactionCategory.values[data.category],
      note: data.note,
      dateTime: data.createdAt,
    );
  }
}
