import 'package:equatable/equatable.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();
}

class TransactionStateInitial extends TransactionState {
  const TransactionStateInitial();

  @override
  List<Object?> get props => [];
}

class TransactionStateLoading extends TransactionState {
  const TransactionStateLoading();

  @override
  List<Object?> get props => [];
}

class TransactionStateSuccess extends TransactionState {
  const TransactionStateSuccess();

  @override
  List<Object?> get props => [];
}

class TransactionStateError extends TransactionState {
  final String message;

  const TransactionStateError(this.message);

  @override
  List<Object?> get props => [message];
}
