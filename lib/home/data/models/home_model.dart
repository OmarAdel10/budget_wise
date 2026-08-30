// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:budget_wise/shared/data/models/financial_breakdown_item.dart';
import 'package:equatable/equatable.dart';

import 'package:budget_wise/transaction/data/models/transaction_model.dart';

class HomeModel extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final DateTime currentMonth;
  final String? filterAccountId;
  final String? selectedCategoryId;
  final List<FinancialBreakdownItem> categories;
  final List<TransactionModel> transactions;

  const HomeModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.currentMonth,
    this.filterAccountId,
    this.selectedCategoryId,
    required this.categories,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpenses,
    currentMonth,
    filterAccountId,
    selectedCategoryId,
    categories,
    transactions,
  ];

  HomeModel copyWith({
    double? totalIncome,
    double? totalExpenses,
    DateTime? currentMonth,
    String? filterAccountId,
    String? selectedCategoryId,
    List<FinancialBreakdownItem>? categories,
    List<TransactionModel>? transactions,
    bool clearFilteredAccountId = false,
    bool clearSelectedCategoryId = false,
  }) {
    return HomeModel(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      currentMonth: currentMonth ?? this.currentMonth,
      filterAccountId: clearFilteredAccountId
          ? null
          : (filterAccountId ?? this.filterAccountId),
      selectedCategoryId: clearSelectedCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'currentMonth': currentMonth.millisecondsSinceEpoch,
      'filterAccountId': filterAccountId,
      'selectedCategoryId': selectedCategoryId,
      'categories': categories.map((x) => x.toMap()).toList(),
      'transactions': transactions.map((x) => x.toMap()).toList(),
    };
  }

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    return HomeModel(
      totalIncome: (map['totalIncome'] as num).toDouble(),
      totalExpenses: (map['totalExpenses'] as num).toDouble(),
      currentMonth: DateTime.fromMillisecondsSinceEpoch(
        map['currentMonth'] as int,
      ),
      filterAccountId: map['filterAccountId'] as String?,
      selectedCategoryId: map['selectedCategoryId'] as String?,
      categories: List<FinancialBreakdownItem>.from(
        (map['categories'] as List<dynamic>).map<FinancialBreakdownItem>(
          (x) => FinancialBreakdownItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      transactions: List<TransactionModel>.from(
        (map['transactions'] as List<dynamic>).map<TransactionModel>(
          (x) => TransactionModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeModel.fromJson(String source) =>
      HomeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
