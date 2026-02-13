import 'package:budget_wise/accounts/data/models/sms_draft_model.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';

class TransactionState extends Equatable {
  final List<TransactionModel> transactionsList;
  final List<SmsDraftModel> pendingSmsTransactions;
  final String? errorMessage;

  const TransactionState({
    this.transactionsList = const [],
    this.pendingSmsTransactions = const [],
    this.errorMessage,
  });

  factory TransactionState.initial() => const TransactionState();

  TransactionState copyWith({
    List<TransactionModel>? transactionsList,
    List<SmsDraftModel>? pendingSmsTransactions,
    String? errorMessage,
  }) {
    return TransactionState(
      transactionsList: transactionsList ?? this.transactionsList,
      pendingSmsTransactions:
          pendingSmsTransactions ?? this.pendingSmsTransactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transactionsList': transactionsList.map((x) => x.toMap()).toList(),
      'pendingSmsTransactions': pendingSmsTransactions
          .map((x) => x.toMap())
          .toList(),
      'errorMessage': errorMessage,
    };
  }

  factory TransactionState.fromMap(Map<String, dynamic> map) {
    return TransactionState(
      transactionsList: List<TransactionModel>.from(
        (map['transactionsList'] as List<dynamic>).map<TransactionModel>(
          (x) => TransactionModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      pendingSmsTransactions: List<SmsDraftModel>.from(
        (map['pendingSmsTransactions'] as List<dynamic>).map<SmsDraftModel>(
          (x) => SmsDraftModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      errorMessage: map['errorMessage'] != null
          ? map['errorMessage'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionState.fromJson(String source) =>
      TransactionState.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
    transactionsList,
    pendingSmsTransactions,
    errorMessage,
  ];
}
