// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final String transactionTitle;
  final double transactionAmount;
  final String categoryId;
  final String accountId;
  final DateTime transactionDate;
  final String? transactionNotes;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    this.id = '',
    this.userId = '',
    required this.type,
    required this.transactionTitle,
    required this.transactionAmount,
    required this.categoryId,
    required this.accountId,
    required this.transactionDate,
    this.transactionNotes = '',
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'type': type.name,
      'transactionTitle': transactionTitle,
      'transactionAmount': transactionAmount,
      'categoryId': categoryId,
      'accountId': accountId,
      'transactionDate': transactionDate.toIso8601String(),
      'transactionNotes': transactionNotes,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'] as String,
      ),
      transactionTitle: map['transactionTitle'] as String,
      transactionAmount: map['transactionAmount'] as double,
      categoryId: map['categoryId'] as String,
      accountId: map['accountId'] as String,
      transactionDate: map['transactionDate'] is Timestamp
          ? (map['transactionDate'] as Timestamp).toDate()
          : DateTime.parse(map['transactionDate'] as String),
      transactionNotes: map['transactionNotes'] != null
          ? map['transactionNotes'] as String
          : '',
      isSynced: map['isSynced'] as bool,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  TransactionModel copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    String? transactionTitle,
    double? transactionAmount,
    String? categoryId,
    String? accountId,
    DateTime? transactionDate,
    String? transactionNotes,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      transactionTitle: transactionTitle ?? this.transactionTitle,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionNotes: transactionNotes ?? this.transactionNotes,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
