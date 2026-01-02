import 'package:budget_wise/home/data/repositories/transaction_repository.dart';
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionStateInitial()) {
    final transactionRepository = TransactionRepository();
    on<TransactionEventCreateTransaction>((event, emit) {
      emit(TransactionStateLoading());
      try {
        transactionRepository.addTransaction(event.transaction);
        emit(TransactionStateSuccess());
      } catch (e) {
        emit(TransactionStateError(e.toString()));
      }
    });

    on<TransactionEventUpdateUserIdInAllTransactionsAfterFirstTimeLoginOnly>((event, emit) {
      emit(TransactionStateLoading());
      try {
        transactionRepository.updateUserIdInAllTransactionsAfterFirstTimeLoginOnly();
        emit(TransactionStateSuccess());
      } catch (e) {
        emit(TransactionStateError(e.toString()));
      }
    });
  }
}
