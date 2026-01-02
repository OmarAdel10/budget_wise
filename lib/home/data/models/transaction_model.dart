// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';


enum TransactionType { income, expense }

class TransactionModel {
  String id;
  String userId;
  final TransactionType type;
  final String transactionTitle;
  final double transactionAmount;
  final String categoryId;
  final DateTime transactionDate;
  final String? transactionNotes;

  TransactionModel({
    this.id = '',
    this.userId = '',
    required this.type,
    required this.transactionTitle,
    required this.transactionAmount,
    required this.categoryId,
    required this.transactionDate,
    this.transactionNotes = '',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'type': type.name,
      'transactionTitle': transactionTitle,
      'transactionAmount': transactionAmount,
      'categoryId': categoryId,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'transactionNotes': transactionNotes,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: TransactionType.values.firstWhere((e) => e.name == map['type'] as String),
      transactionTitle: map['transactionTitle'] as String,
      transactionAmount: map['transactionAmount'] as double,
      categoryId: map['categoryId'] as String,
      transactionDate: Timestamp.fromDate(map['transactionDate'] as DateTime).toDate(),
      transactionNotes: map['transactionNotes'] != null ? map['transactionNotes'] as String : '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
