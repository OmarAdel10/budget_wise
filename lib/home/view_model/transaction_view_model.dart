import 'dart:async';
import 'dart:developer';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/home/data/models/transaction_model.dart';
import 'package:budget_wise/home/data/repositories/transaction_repository.dart';
import 'package:budget_wise/home/view_model/transaction_event.dart';
import 'package:budget_wise/home/view_model/transaction_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

class TransactionBloc extends HydratedBloc<TransactionEvent, TransactionState> {
  final SettingsBloc settingsBloc;
  final AuthRepository authRepository;
  final TransactionRepository transactionRepository;
  TransactionBloc({
    required this.settingsBloc,
    required this.authRepository,
    required this.transactionRepository,
  }) : super(const TransactionStateInitial(transactionsList: [])) {
    authRepository.authStateChanges.listen((user) {
      if (user != null && settingsBloc.state.model.isSyncToCloudEnabled) {
        add(const TransactionEventFetchAll());
      }
    });
    on<TransactionEventCreateTransaction>((event, emit) async {
      try {
        final userId = authRepository.currentUser?.uid ?? '';
        final newTransaction = event.transaction
          ..id = const Uuid().v4()
          ..userId = userId;
        final updatedList = [newTransaction, ...state.transactionsList];

        emit(TransactionStateSuccess(transactionsList: updatedList));
        if (settingsBloc.state.model.isSyncToCloudEnabled == true) {
          transactionRepository
              .addTransaction(newTransaction)
              .then((_) {
                add(
                  TransactionEventMarkSynced(transactionId: newTransaction.id),
                );
              })
              .catchError((e) {
                emit(
                  TransactionStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    transactionsList: state.transactionsList,
                  ),
                );
              });
        }
      } catch (e) {
        emit(
          TransactionStateError(
            message: 'Local storage failed: ${e.toString()}',
            transactionsList: state.transactionsList,
          ),
        );
      }
    });

    on<TransactionEventUpdateTransaction>((event, emit) async {
      try {
        final updatedTransaction = event.transaction;
        final updatedList = state.transactionsList.map((transaction) {
          return transaction.id == updatedTransaction.id ? updatedTransaction : transaction;
        }).toList();

        emit(TransactionStateSuccess(transactionsList: updatedList));

        if (settingsBloc.state.model.isSyncToCloudEnabled == true) {
          transactionRepository
              .addTransaction(updatedTransaction)
              .then((_) {
            add(TransactionEventMarkSynced(transactionId: updatedTransaction.id));
          }).catchError((e) {
            emit(TransactionStateError(
              message: 'Cloud sync failed: ${e.toString()}',
              transactionsList: state.transactionsList,
            ));
          });
        }
      } catch (e) {
        emit(TransactionStateError(
          message: 'Local update failed: ${e.toString()}',
          transactionsList: state.transactionsList,
        ));
      }
    });

    on<TransactionEventMarkSynced>((event, emit) async {
      try {
        final updatedList = state.transactionsList.map((transaction) {
          if (transaction.id == event.transactionId) {
            return transaction.copyWith(isSynced: true);
          }
          return transaction;
        }).toList();
        emit(TransactionStateSuccess(transactionsList: updatedList));
      } catch (e) {
        emit(
          TransactionStateError(
            message: 'Marking as synced failed: ${e.toString()}',
            transactionsList: state.transactionsList,
          ),
        );
      }
    });
    on<TransactionEventSyncUnsynced>((event, emit) async {
      try {
        final unSynced = state.transactionsList
            .where((transaction) => transaction.isSynced == false)
            .toList();
        if (unSynced.isEmpty) return;
        final synced = unSynced.map((transaction) {
          return transactionRepository.addTransaction(transaction).then((_) {
            add(TransactionEventMarkSynced(transactionId: transaction.id));
          });
        }).toList();
        await Future.wait(synced);
      } catch (e) {
        emit(
          TransactionStateError(
            message: 'Marking as unsynced failed: ${e.toString()}',
            transactionsList: state.transactionsList,
          ),
        );
      }
    });

    on<TransactionEventUpdateUserIdInAllCategoriesAfterFirstTimeLoginOnly>((
      event,
      emit,
    ) {
      try {
        final userId = authRepository.currentUser?.uid;
        if (userId != null) {
          final updatedList = state.transactionsList.map((transaction) {
            if (transaction.userId.isEmpty) {
              return transaction.copyWith(userId: userId);
            }
            return transaction;
          }).toList();

          if (settingsBloc.state.model.isSyncToCloudEnabled) {
            transactionRepository
                .updateUserIdInAllTransactionsAfterFirstTimeLoginOnly();
          }

          emit(TransactionStateSuccess(transactionsList: updatedList));
        }
      } catch (e) {
        emit(
          TransactionStateError(
            message: e.toString(),
            transactionsList: state.transactionsList,
          ),
        );
      }
    });

    on<TransactionEventFetchAll>((event, emit) async {
      try {
        final transactions = await transactionRepository.fetchAllTransactions();
        emit(TransactionStateSuccess(transactionsList: transactions));
      } catch (e) {
        emit(
          TransactionStateError(
            message: 'Failed to fetch transactions: ${e.toString()}',
            transactionsList: state.transactionsList,
          ),
        );
      }
    });

    on<TransactionEventDeleteTransaction>((event, emit) async {
      try {
        final updatedList = state.transactionsList
            .where((transaction) => transaction.id != event.transactionId)
            .toList();

        emit(TransactionStateSuccess(transactionsList: updatedList));

        if (settingsBloc.state.model.isSyncToCloudEnabled == true) {
          transactionRepository
              .deleteTransaction(event.transactionId)
              .catchError((e) {
            emit(
              TransactionStateError(
                message: 'Cloud sync failed: ${e.toString()}',
                transactionsList: state.transactionsList,
              ),
            );
          });
        }
      } catch (e) {
        emit(
          TransactionStateError(
            message: 'Delete failed: ${e.toString()}',
            transactionsList: state.transactionsList,
          ),
        );
      }
    });
  }

  // @override
  // Future<void> close() {
  //   _authSubscription.cancel();
  //   return super.close();
  // }

  @override
  TransactionState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic>? list = json['transactionsList'];
      if (list == null) {
        return const TransactionStateInitial(transactionsList: []);
      }
      final List<TransactionModel> transactionsList = list
          .map((e) => TransactionModel.fromMap(e))
          .toList();
      return TransactionStateSuccess(transactionsList: transactionsList);
    } catch (e) {
      log('Error During Serialization: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(TransactionState state) {
    return {
      'transactionsList': state.transactionsList
          .map((transaction) => transaction.toSerializableMap())
          .toList(),
    };
  }
}
