// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense, transfer }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final String? description;
  final double transactionAmount;
  final String transactionCurrency;
  final String categoryId;
  final String accountId;
  final String? toAccountId;
  final String? transferGroupId;
  final DateTime transactionDate;
  final String? transactionNotes;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    this.id = '',
    this.userId = '',
    required this.type,
    this.description,
    required this.transactionAmount,
    required this.transactionCurrency,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    this.transferGroupId,
    required this.transactionDate,
    this.transactionNotes,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'type': type.name,
      'description': description,
      'transactionAmount': transactionAmount,
      'transactionCurrency': transactionCurrency,
      'categoryId': categoryId,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'transferGroupId': transferGroupId,
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
      description: (map['description'] ?? map['transactionTitle']) as String?,
      transactionAmount: map['transactionAmount'] as double,
      transactionCurrency: map['transactionCurrency'] as String,
      categoryId: map['categoryId'] as String,
      accountId: map['accountId'] as String,
      toAccountId: map['toAccountId'] as String?,
      transferGroupId: map['transferGroupId'] as String?,
      transactionDate: map['transactionDate'] is Timestamp
          ? (map['transactionDate'] as Timestamp).toDate()
          : DateTime.parse(map['transactionDate'] as String),
      transactionNotes: map['transactionNotes'] as String?,
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
    String? description,
    double? transactionAmount,
    String? transactionCurrency,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    String? transferGroupId,
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
      description: description ?? this.description,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      transactionCurrency: transactionCurrency ?? this.transactionCurrency,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      transferGroupId: transferGroupId ?? this.transferGroupId,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionNotes: transactionNotes ?? this.transactionNotes,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
