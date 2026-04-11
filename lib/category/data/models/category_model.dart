// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:budget_wise/shared/data/models/statistics_representable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:budget_wise/transaction/data/models/transaction_model.dart';

class CategoryModel implements FinancialRepresentable {
  final String id;
  final String userId;
  final String categoryTitle;
  final IconData categoryIcon;
  final bool hasBudgetAmount;
  final double? budgetAmount;
  final TransactionType type;
  final bool isSynced;
  final int index;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String get financialId => id;

  @override
  String get financialTitle => categoryTitle;

  @override
  IconData get financialIcon => categoryIcon;

  @override
  Color? get financialColor => null;

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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] as String),
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory CategoryModel.empty() => CategoryModel(
    id: '',
    categoryTitle: '',
    categoryIcon: Icons.category,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
