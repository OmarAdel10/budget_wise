import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';

class TransactionState extends Equatable {
  final List<TransactionModel> transactionsList;
  final List<TransactionModel> recentTransactions;
  final double currentAccountBalance;
  final DateTime? lastAccountUpdatedAt;
  final String? selectedAccountId;
  final List<SmsDraftModel> pendingSmsTransactions;
  final bool isProcessingBackgroundDrafts;
  final String? errorMessage;

  const TransactionState({
    this.transactionsList = const [],
    this.recentTransactions = const [],
    this.currentAccountBalance = 0.0,
    this.lastAccountUpdatedAt,
    this.selectedAccountId,
    this.pendingSmsTransactions = const [],
    this.isProcessingBackgroundDrafts = false,
    this.errorMessage,
  });

  factory TransactionState.initial() => const TransactionState();

  TransactionState copyWith({
    List<TransactionModel>? transactionsList,
    List<TransactionModel>? recentTransactions,
    double? currentAccountBalance,
    DateTime? lastAccountUpdatedAt,
    String? selectedAccountId,
    List<SmsDraftModel>? pendingSmsTransactions,
    bool? isProcessingBackgroundDrafts,
    String? errorMessage,
  }) {
    return TransactionState(
      transactionsList: transactionsList ?? this.transactionsList,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      currentAccountBalance:
          currentAccountBalance ?? this.currentAccountBalance,
      lastAccountUpdatedAt: lastAccountUpdatedAt ?? this.lastAccountUpdatedAt,
      selectedAccountId: selectedAccountId ?? this.selectedAccountId,
      pendingSmsTransactions:
          pendingSmsTransactions ?? this.pendingSmsTransactions,
      isProcessingBackgroundDrafts:
          isProcessingBackgroundDrafts ?? this.isProcessingBackgroundDrafts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transactionsList': transactionsList.map((x) => x.toMap()).toList(),
      'recentTransactions': recentTransactions.map((x) => x.toMap()).toList(),
      'currentAccountBalance': currentAccountBalance,
      'lastAccountUpdatedAt': lastAccountUpdatedAt?.toIso8601String(),
      'selectedAccountId': selectedAccountId,
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
      recentTransactions: map['recentTransactions'] != null
          ? List<TransactionModel>.from(
              (map['recentTransactions'] as List<dynamic>)
                  .map<TransactionModel>(
                    (x) => TransactionModel.fromMap(x as Map<String, dynamic>),
                  ),
            )
          : const [],
      currentAccountBalance:
          (map['currentAccountBalance'] as num?)?.toDouble() ?? 0.0,
      lastAccountUpdatedAt: map['lastAccountUpdatedAt'] != null
          ? DateTime.parse(map['lastAccountUpdatedAt'] as String)
          : null,
      selectedAccountId: map['selectedAccountId'] as String?,
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

  List<TransactionModel> getSubscriptionHistory({
    required String categoryId,
    required String name,
  }) {
    return transactionsList
        .where(
          (t) =>
              t.categoryId == categoryId &&
              (t.description ?? '').toLowerCase().contains(name.toLowerCase()),
        )
        .toList();
  }

  double getCategorySpending({
    required String categoryId,
    required int month,
    required int year,
    String? excludeTransactionId,
  }) {
    return transactionsList
        .where(
          (t) =>
              t.categoryId == categoryId &&
              t.type == TransactionType.expense &&
              t.transactionDate.month == month &&
              t.transactionDate.year == year &&
              (excludeTransactionId == null || t.id != excludeTransactionId),
        )
        .fold(0.0, (sum, t) => sum + t.transactionAmount);
  }

  @override
  List<Object?> get props => [
    transactionsList,
    recentTransactions,
    currentAccountBalance,
    lastAccountUpdatedAt,
    selectedAccountId,
    pendingSmsTransactions,
    isProcessingBackgroundDrafts,
    errorMessage,
  ];
}
