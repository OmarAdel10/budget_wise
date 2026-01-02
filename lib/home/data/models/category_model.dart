// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:budget_wise/home/data/models/transaction_model.dart';

class CategoryModel {
  String id;
  String userId;
  final String categoryTitle;
  final IconData categoryIcon;
  final double budgetAmount;
  final TransactionType type;

  CategoryModel({
    this.id = '',
    this.userId = '',
    required this.categoryTitle,
    required this.categoryIcon,
    required this.budgetAmount,
    this.type = TransactionType.expense,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'categoryTitle': categoryTitle,
      'categoryIcon': categoryIcon.codePoint,
      'budgetAmount': budgetAmount,
      'type': type.name,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      categoryTitle: map['categoryTitle'] as String,
      categoryIcon: IconData(map['categoryIcon'] as int),
      budgetAmount: map['budgetAmount'] as double,
      type: map['type'] != null
          ? TransactionType.values.firstWhere((e) => e.name == map['type'])
          : TransactionType.expense,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) => CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
