import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:equatable/equatable.dart';

sealed class TransactionState extends Equatable {
  final List<TransactionModel> transactionsList;
  const TransactionState({required this.transactionsList});
}

class TransactionStateInitial extends TransactionState {
  const TransactionStateInitial({required super.transactionsList});

  @override
  List<Object?> get props => [transactionsList];
}

class TransactionStateSuccess extends TransactionState {
  const TransactionStateSuccess({required super.transactionsList});

  @override
  List<Object?> get props => [transactionsList];
}

class TransactionStateError extends TransactionState {
  final String message;

  const TransactionStateError({required this.message, required super.transactionsList});

  @override
  List<Object?> get props => [message, transactionsList];
}
