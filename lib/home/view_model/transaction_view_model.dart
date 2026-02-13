import 'dart:developer';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
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
  final AccountBloc accountBloc;
  final TransactionRepository transactionRepository;
  final AuthRepository authRepository;

  TransactionBloc({
    required this.settingsBloc,
    required this.accountBloc,
    required this.transactionRepository,
    required this.authRepository,
  }) : super(TransactionState.initial()) {
    authRepository.authStateChanges.listen((user) {
      if (user != null && settingsBloc.state.model.hasLoggedIn) {
        add(const TransactionEventFetchAll());
      }
    });
    on<TransactionEventCreateTransaction>((event, emit) async {
      try {
        final userId = authRepository.currentUser?.uid ?? '';
        final newTransaction = event.transaction.copyWith(
          id: event.transaction.id.isEmpty
              ? const Uuid().v4()
              : event.transaction.id,
          userId: userId,
          isSynced: false,
        );

        final updatedList = [newTransaction, ...state.transactionsList];

        emit(state.copyWith(transactionsList: updatedList, errorMessage: null));

        // Update Account Balance
        final amountDelta = newTransaction.type == TransactionType.income
            ? newTransaction.transactionAmount
            : -newTransaction.transactionAmount;
        if (newTransaction.accountId.isNotEmpty) {
          accountBloc.add(
            AccountEventUpdateBalance(
              accountId: newTransaction.accountId,
              amountDelta: amountDelta,
            ),
          );
        }
        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          transactionRepository
              .addTransaction(newTransaction)
              .then((_) {
                add(
                  TransactionEventMarkSynced(transactionId: newTransaction.id),
                );
              })
              .catchError((e) {
                emit(
                  state.copyWith(
                    errorMessage: 'Cloud sync failed: ${e.toString()}',
                  ),
                );
              });
        }
      } catch (e) {
        emit(
          state.copyWith(errorMessage: 'Local storage failed: ${e.toString()}'),
        );
      }
    });

    on<TransactionEventUpdateTransaction>((event, emit) async {
      try {
        final updatedTransaction = event.transaction.copyWith(isSynced: false);
        final oldTransaction = state.transactionsList.firstWhere(
          (t) => t.id == updatedTransaction.id,
        );

        final updatedList = state.transactionsList.map((transaction) {
          return transaction.id == updatedTransaction.id
              ? updatedTransaction
              : transaction;
        }).toList();

        emit(state.copyWith(transactionsList: updatedList, errorMessage: null));

        // Update Account Balance
        if (oldTransaction.accountId == updatedTransaction.accountId) {
          // Same account, update with diff
          final oldAmountDelta = oldTransaction.type == TransactionType.income
              ? oldTransaction.transactionAmount
              : -oldTransaction.transactionAmount;
          final newAmountDelta =
              updatedTransaction.type == TransactionType.income
              ? updatedTransaction.transactionAmount
              : -updatedTransaction.transactionAmount;
          final diff = newAmountDelta - oldAmountDelta;

          if (diff != 0 && updatedTransaction.accountId.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: updatedTransaction.accountId,
                amountDelta: diff,
              ),
            );
          }
        } else {
          // Different account: reverse old, apply new
          final oldAmountReversal =
              oldTransaction.type == TransactionType.income
              ? -oldTransaction.transactionAmount
              : oldTransaction.transactionAmount;
          final newAmountDelta =
              updatedTransaction.type == TransactionType.income
              ? updatedTransaction.transactionAmount
              : -updatedTransaction.transactionAmount;

          if (oldTransaction.accountId.isNotEmpty &&
              updatedTransaction.accountId.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: oldTransaction.accountId,
                amountDelta: oldAmountReversal,
              ),
            );
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: updatedTransaction.accountId,
                amountDelta: newAmountDelta,
              ),
            );
          }
        }

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          transactionRepository
              .addTransaction(updatedTransaction)
              .then((_) {
                add(
                  TransactionEventMarkSynced(
                    transactionId: updatedTransaction.id,
                  ),
                );
              })
              .catchError((e) {
                emit(
                  state.copyWith(
                    errorMessage: 'Cloud sync failed: ${e.toString()}',
                  ),
                );
              });
        }
      } catch (e) {
        emit(
          state.copyWith(errorMessage: 'Local update failed: ${e.toString()}'),
        );
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
        emit(state.copyWith(transactionsList: updatedList, errorMessage: null));
      } catch (e) {
        emit(
          state.copyWith(
            errorMessage: 'Marking as synced failed: ${e.toString()}',
          ),
        );
      }
    });

    on<TransactionEventFetchAll>((event, emit) async {
      try {
        final remoteTransactions = await transactionRepository
            .fetchAllTransactions();

        final localTransactionsMap = {
          for (final t in state.transactionsList) t.id: t,
        };

        final updatedList = <TransactionModel>[];

        for (final remoteItem in remoteTransactions) {
          final localItem = localTransactionsMap[remoteItem.id];

          if (localItem == null) {
            updatedList.add(remoteItem);
          } else {
            if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
              updatedList.add(remoteItem);
            } else {
              updatedList.add(localItem);
            }
            localTransactionsMap.remove(remoteItem.id);
          }
        }
        updatedList.addAll(localTransactionsMap.values);

        updatedList.sort(
          (a, b) => b.transactionDate.compareTo(a.transactionDate),
        );

        emit(state.copyWith(transactionsList: updatedList, errorMessage: null));
      } catch (e) {
        emit(
          state.copyWith(
            errorMessage: 'Failed to fetch transactions: ${e.toString()}',
          ),
        );
      }
    });

    on<TransactionEventDeleteTransaction>((event, emit) async {
      try {
        final transactionToDelete = state.transactionsList.firstWhere(
          (t) => t.id == event.transactionId,
        );

        final updatedList = state.transactionsList
            .where((transaction) => transaction.id != event.transactionId)
            .toList();

        emit(state.copyWith(transactionsList: updatedList, errorMessage: null));

        // Reverse Account Balance
        final reversalDelta = transactionToDelete.type == TransactionType.income
            ? -transactionToDelete.transactionAmount
            : transactionToDelete.transactionAmount;

        accountBloc.add(
          AccountEventUpdateBalance(
            accountId: transactionToDelete.accountId,
            amountDelta: reversalDelta,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          await transactionRepository
              .deleteTransaction(event.transactionId)
              .catchError((e) {
                // Restore transaction to list and mark as unsynced for retry
                final restoredList = [
                  transactionToDelete,
                  ...state.transactionsList,
                ];
                emit(
                  state.copyWith(
                    transactionsList: restoredList,
                    errorMessage:
                        'Cloud delete failed. Will retry on next sync.',
                  ),
                );
                log('Failed to delete transaction ${event.transactionId}: $e');
              });
        }
      } catch (e) {
        emit(state.copyWith(errorMessage: 'Delete failed: ${e.toString()}'));
      }
    });

    on<TransactionEventSyncPendingOnLogin>((event, emit) async {
      try {
        final pendingTransactions = state.transactionsList
            .where(
              (transaction) =>
                  transaction.isSynced == false &&
                  authRepository.currentUser != null,
            )
            .toList();
        if (pendingTransactions.isEmpty) return;
        for (final transaction in pendingTransactions) {
          final transactionWithUserId = transaction.copyWith(
            userId: authRepository.currentUser!.uid,
          );
          await transactionRepository
              .addTransaction(transactionWithUserId)
              .then(
                (_) => add(
                  TransactionEventMarkSynced(
                    transactionId: transactionWithUserId.id,
                  ),
                ),
              )
              .catchError((e) {
                log(
                  'Failed to sync transaction ${transaction.id} on login: $e',
                );
              });
        }
      } catch (e) {
        emit(
          state.copyWith(errorMessage: 'Sync on login failed: ${e.toString()}'),
        );
      }
    });

    on<TransactionEventCheckAndSyncPending>((event, emit) async {
      try {
        if (authRepository.currentUser == null) return;

        final pendingTransactions = state.transactionsList
            .where((t) => t.isSynced == false)
            .toList();
        if (pendingTransactions.isEmpty) return;
        for (var transaction in pendingTransactions) {
          await transactionRepository
              .addTransaction(transaction)
              .then(
                (_) => add(
                  TransactionEventMarkSynced(transactionId: transaction.id),
                ),
              )
              .catchError((e) {
                log('Failed to sync transaction ${transaction.id}: $e');
              });
        }
      } catch (e) {
        emit(
          state.copyWith(
            errorMessage: 'Check and sync failed: ${e.toString()}',
          ),
        );
      }
    });

    on<TransactionEventAddSmsDraft>((event, emit) {
      final newDraft = event.smsDraft.copyWith(
        id: (event.smsDraft.id.isEmpty)
            ? const Uuid().v4()
            : event.smsDraft.id,
      );

      final updatedDrafts = [newDraft, ...state.pendingSmsTransactions];
      emit(state.copyWith(pendingSmsTransactions: updatedDrafts));
    });

    on<TransactionEventConfirmSmsDraft>((event, emit) async {
      final updatedDrafts = state.pendingSmsTransactions
          .where((draft) => draft.id != event.smsDraftId)
          .toList();

      emit(
        state.copyWith(
          pendingSmsTransactions: updatedDrafts,
          errorMessage: null,
        ),
      );

      // Delegate creation to TransactionEventCreateTransaction
      add(TransactionEventCreateTransaction(event.transaction));
    });

    on<TransactionEventDeclineSmsDraft>((event, emit) {
      final updatedDrafts = state.pendingSmsTransactions
          .where(
            (draft) => draft.id != event.smsDraftId,
          )
          .toList();
      emit(state.copyWith(pendingSmsTransactions: updatedDrafts));
    });

    on<TransactionEventUpdateSmsDraft>((event, emit) {
      final updatedDrafts = state.pendingSmsTransactions.map((draft) {
        return draft.id == event.updatedDraft.id ? event.updatedDraft : draft;
      }).toList();
      emit(state.copyWith(pendingSmsTransactions: updatedDrafts));
    });
  }

  @override
  TransactionState? fromJson(Map<String, dynamic> json) {
    try {
      return TransactionState.fromMap(json);
    } catch (e) {
      log('Error During Deserialization: $e'); // Corrected log message
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(TransactionState state) {
    return state.toMap();
  }
}
