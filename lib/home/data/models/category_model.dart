// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:budget_wise/home/data/models/transaction_model.dart';

class CategoryModel {
  String id;
  String userId;
  final String categoryTitle;
  final IconData categoryIcon;
  final bool hasBudgetAmount;
  final double? budgetAmount;
  final TransactionType type;
  final bool isSynced;
  final int index;

  CategoryModel({
    this.id = '',
    this.userId = '',
    required this.categoryTitle,
    required this.categoryIcon,
    this.hasBudgetAmount = false,
    this.budgetAmount,
    this.type = TransactionType.expense,
    this.isSynced = false,
    this.index = 0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'categoryTitle': categoryTitle,
      'categoryIcon': categoryIcon.codePoint,
      'categoryIconFontFamily': categoryIcon.fontFamily,
      'categoryIconFontPackage': categoryIcon.fontPackage,
      'hasBudgetAmount': hasBudgetAmount,
      'budgetAmount': budgetAmount,
      'type': type.name,
      'isSynced': isSynced,
      'index': index,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      categoryTitle: map['categoryTitle'] as String,
      categoryIcon: IconData(
        map['categoryIcon'] as int,
        fontFamily: map['categoryIconFontFamily'] as String?,
        fontPackage: map['categoryIconFontPackage'] as String?,
      ),
      hasBudgetAmount: map['hasBudgetAmount'] as bool,
      budgetAmount: (map['budgetAmount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] != null
          ? TransactionType.values.firstWhere((e) => e.name == map['type'])
          : TransactionType.expense,
      isSynced: map['isSynced'] as bool,
      index: map['index'] as int? ?? 0,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? categoryTitle,
    IconData? categoryIcon,
    bool? hasBudgetAmount,
    double? budgetAmount,
    TransactionType? type,
    bool? isSynced,
    int? index,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      hasBudgetAmount: hasBudgetAmount ?? this.hasBudgetAmount,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      type: type ?? this.type,
      isSynced: isSynced ?? this.isSynced,
      index: index ?? this.index,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
