// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:budget_wise/home/data/models/category_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';

class HomeModel extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final DateTime currentMonth;
  final List<CategoriesWithSpending> categories;
  final List<TransactionModel> transactions;

  const HomeModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.currentMonth,
    required this.categories,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpenses,
    currentMonth,
    categories,
    transactions,
  ];

  HomeModel copyWith({
    double? totalIncome,
    double? totalExpenses,
    DateTime? currentMonth,
    List<CategoriesWithSpending>? categories,
    List<TransactionModel>? transactions,
  }) {
    return HomeModel(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      currentMonth: currentMonth ?? this.currentMonth,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'currentMonth': currentMonth.millisecondsSinceEpoch,
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

  const CategoriesWithSpending(this.category, this.totalSpending);

  @override
  List<Object?> get props => [category, totalSpending];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'category': category.toMap(),
      'totalSpending': totalSpending,
    };
  }

  factory CategoriesWithSpending.fromMap(Map<String, dynamic> map) {
    return CategoriesWithSpending(
      CategoryModel.fromMap(map['category'] as Map<String, dynamic>),
      map['totalSpending'] as double,
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
  }) {
    return CategoriesWithSpending(
      category ?? this.category,
      totalSpending ?? this.totalSpending,
    );
  }
}
