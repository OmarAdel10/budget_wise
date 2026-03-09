// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:budget_wise/category/data/models/category_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';

class HomeModel extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final DateTime currentMonth;
  final String? filterAccountId;
  final List<CategoriesWithSpending> categories;
  final List<TransactionModel> transactions;

  const HomeModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.currentMonth,
    this.filterAccountId,
    required this.categories,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpenses,
    currentMonth,
    filterAccountId,
    categories,
    transactions,
  ];

  HomeModel copyWith({
    double? totalIncome,
    double? totalExpenses,
    DateTime? currentMonth,
    String? filterAccountId,
    List<CategoriesWithSpending>? categories,
    List<TransactionModel>? transactions,
    bool clearFilteredAccountId = false,
  }) {
    return HomeModel(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      currentMonth: currentMonth ?? this.currentMonth,
      filterAccountId: clearFilteredAccountId
          ? null
          : (filterAccountId ?? this.filterAccountId),
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
      categories: List<CategoriesWithSpending>.from(
        (map['categories'] as List<dynamic>).map<CategoriesWithSpending>(
          (x) => CategoriesWithSpending.fromMap(x as Map<String, dynamic>),
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

class CategoriesWithSpending extends Equatable {
  final CategoryModel category;
  final double totalSpending;
  final double percentage;

  const CategoriesWithSpending(
    this.category,
    this.totalSpending, {
    this.percentage = 0.0,
  });

  @override
  List<Object?> get props => [category, totalSpending, percentage];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'category': category.toMap(),
      'totalSpending': totalSpending,
      'percentage': percentage,
    };
  }

  factory CategoriesWithSpending.fromMap(Map<String, dynamic> map) {
    return CategoriesWithSpending(
      CategoryModel.fromMap(map['category'] as Map<String, dynamic>),
      (map['totalSpending'] as num).toDouble(),
      percentage: (map['percentage'] as num? ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriesWithSpending.fromJson(String source) =>
      CategoriesWithSpending.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  CategoriesWithSpending copyWith({
    CategoryModel? category,
    double? totalSpending,
    double? percentage,
  }) {
    return CategoriesWithSpending(
      category ?? this.category,
      totalSpending ?? this.totalSpending,
      percentage: percentage ?? this.percentage,
    );
  }
}
