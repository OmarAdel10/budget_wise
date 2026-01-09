import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:equatable/equatable.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();
}

class TransactionEventCreateTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const TransactionEventCreateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionEventUpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const TransactionEventUpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionEventMarkSynced extends TransactionEvent {
  final String transactionId;
  const TransactionEventMarkSynced({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class TransactionEventSyncUnsynced extends TransactionEvent {
  const TransactionEventSyncUnsynced();

  @override
  List<Object?> get props => [];
}

class TransactionEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly
    extends TransactionEvent {
  const TransactionEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly();

  @override
  List<Object?> get props => [];
}

class TransactionEventFetchAll extends TransactionEvent {
  const TransactionEventFetchAll();

  @override
  List<Object?> get props => [];
}

class TransactionEventDeleteTransaction extends TransactionEvent {
  final String transactionId;

  const TransactionEventDeleteTransaction({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
