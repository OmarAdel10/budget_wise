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

class TransactionEventLoadTransactions extends TransactionEvent {
  const TransactionEventLoadTransactions();

  @override
  List<Object?> get props => [];
}

class TransactionEventUpdateUserIdInAllTransactionsAfterFirstTimeLoginOnly extends TransactionEvent {
  const TransactionEventUpdateUserIdInAllTransactionsAfterFirstTimeLoginOnly();

  @override
  List<Object?> get props => [];
}
