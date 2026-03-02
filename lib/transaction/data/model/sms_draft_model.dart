import 'dart:convert';
import 'package:budget_wise/transaction/data/model/transaction_model.dart';
import 'package:equatable/equatable.dart';

class SmsDraftModel extends Equatable {
  final String id;
  final String sender;
  final String body;
  final String? extractedMerchant;
  final double? extractedAmount;
  final String? extractedCurrency;
  final DateTime? extractedDate;
  final String? extractedCardLastFour;
  final TransactionType transactionType;
  final String? matchedAccountId;
  final DateTime timestamp;

  const SmsDraftModel({
    this.id = '',
    required this.sender,
    required this.body,
    this.extractedMerchant,
    this.extractedAmount,
    this.extractedCurrency,
    this.extractedDate,
    this.extractedCardLastFour,
    required this.transactionType,
    this.matchedAccountId,
    required this.timestamp,
  });

  SmsDraftModel copyWith({
    String? id,
    String? sender,
    String? body,
    String? extractedMerchant,
    double? extractedAmount,
    String? extractedCurrency,
    DateTime? extractedDate,
    String? extractedCardLastFour,
    TransactionType? transactionType,
    String? matchedAccountId,
    DateTime? timestamp,
  }) {
    return SmsDraftModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      extractedMerchant: extractedMerchant ?? this.extractedMerchant,
      extractedAmount: extractedAmount ?? this.extractedAmount,
      extractedCurrency: extractedCurrency ?? this.extractedCurrency,
      extractedDate: extractedDate ?? this.extractedDate,
      extractedCardLastFour:
          extractedCardLastFour ?? this.extractedCardLastFour,
      transactionType: transactionType ?? this.transactionType,
      matchedAccountId: matchedAccountId ?? this.matchedAccountId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sender': sender,
      'body': body,
      'extractedMerchant': extractedMerchant,
      'extractedAmount': extractedAmount,
      'extractedCurrency': extractedCurrency,
      'extractedDate': extractedDate?.toIso8601String(),
      'extractedCardLastFour': extractedCardLastFour,
      'transactionType': transactionType.name,
      'matchedAccountId': matchedAccountId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SmsDraftModel.fromMap(Map<String, dynamic> map) {
    return SmsDraftModel(
      id: map['id'] as String,
      sender: map['sender'] as String,
      body: map['body'] as String,
      extractedMerchant: map['extractedMerchant'] != null
          ? map['extractedMerchant'] as String
          : null,
      extractedAmount: map['extractedAmount'] != null
          ? map['extractedAmount'] as double
          : null,
      extractedCurrency: map['extractedCurrency'] != null
          ? map['extractedCurrency'] as String
          : null,
      extractedDate: map['extractedDate'] != null
          ? DateTime.parse(map['extractedDate'] as String)
          : null,
      extractedCardLastFour: map['extractedCardLastFour'] != null
          ? map['extractedCardLastFour'] as String
          : null,
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == map['transactionType'],
      ),
      matchedAccountId: map['matchedAccountId'] != null
          ? map['matchedAccountId'] as String
          : null,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory SmsDraftModel.fromJson(String source) =>
      SmsDraftModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
    id,
    sender,
    body,
    extractedMerchant,
    extractedAmount,
    extractedCurrency,
    extractedDate,
    extractedCardLastFour,
    transactionType,
    matchedAccountId,
    timestamp,
  ];
}
