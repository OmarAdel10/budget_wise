import 'dart:developer';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/category/data/constants/system_category_ids.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/transaction/data/models/transaction_extensions.dart';
import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/data/repositories/transaction_repository.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';

class TransactionBloc extends HydratedBloc<TransactionEvent, TransactionState> {
  final SettingsBloc settingsBloc;
  final AccountBloc accountBloc;
  final CategoryBloc categoryBloc;
  final TransactionRepository transactionRepository;
  final AuthRepository authRepository;

  TransactionBloc({
    required this.settingsBloc,
    required this.accountBloc,
    required this.categoryBloc,
    required this.transactionRepository,
    required this.authRepository,
  }) : super(TransactionState.initial()) {
    if (state.transactionsList.isNotEmpty) {
      categoryBloc.add(
        CategoryEventRefreshTotals(transactions: state.transactionsList),
      );
    }

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

        _emitUpdatedState(
          emit,
          state.copyWith(transactionsList: updatedList, errorMessage: null),
        );
        categoryBloc.add(CategoryEventRefreshTotals(transactions: updatedList));

        // Update Account Balance
        final amountForAccount =
            event.convertedAmount ?? newTransaction.transactionAmount;

        if (newTransaction.type == TransactionType.transfer) {
          // Dual update for transfers
          if (newTransaction.accountId.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: newTransaction.accountId,
                amountDelta: -amountForAccount,
              ),
            );
          }
          if (newTransaction.toAccountId != null &&
              newTransaction.toAccountId!.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: newTransaction.toAccountId!,
                amountDelta: amountForAccount,
              ),
            );
          }
        } else {
          // Standard single account update
          final amountDelta = newTransaction.type == TransactionType.income
              ? amountForAccount
              : -amountForAccount;
          if (newTransaction.accountId.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: newTransaction.accountId,
                amountDelta: amountDelta,
              ),
            );
          }
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

        // Budget Warning Alert logic
        _checkBudgetLimit(
          transaction: newTransaction,
          updatedList: updatedList,
          toastCallback: event.toastCallback,
        );
      } catch (e) {
        emit(
          state.copyWith(errorMessage: 'Local storage failed: ${e.toString()}'),
        );
      }
    });

    on<TransactionEventCreateTransfer>((event, emit) async {
      try {
        final userId = authRepository.currentUser?.uid ?? '';
        final groupId = const Uuid().v4();
        final now = DateTime.now();
        final categoryId =
            event.categoryId ?? SystemCategoryIds.accountTransfer;

        final expenseLeg = TransactionModel(
          id: const Uuid().v4(),
          userId: userId,
          type: TransactionType.expense,
          description: event.fromDescription,
          transactionAmount: event.amount,
          transactionCurrency: event.fromCurrency,
          categoryId: categoryId,
          accountId: event.fromAccountId,
          toAccountId: event.toAccountId,
          transferGroupId: groupId,
          transactionDate: event.transactionDate,
          transactionNotes: event.transactionNotes,
          isSynced: false,
          createdAt: now,
          updatedAt: now,
        );

        final incomeLeg = TransactionModel(
          id: const Uuid().v4(),
          userId: userId,
          type: TransactionType.income,
          description: event.toDescription,
          transactionAmount: event.destinationAmount,
          transactionCurrency: event.destinationCurrency,
          categoryId: categoryId,
          accountId: event.toAccountId,
          transferGroupId: groupId,
          transactionDate: event.transactionDate,
          transactionNotes: event.transactionNotes,
          isSynced: false,
          createdAt: now,
          updatedAt: now,
        );

        final newTransactions = [expenseLeg, incomeLeg];
        final updatedList = [...newTransactions, ...state.transactionsList];

        _emitUpdatedState(
          emit,
          state.copyWith(transactionsList: updatedList, errorMessage: null),
        );
        categoryBloc.add(CategoryEventRefreshTotals(transactions: updatedList));

        accountBloc.add(
          AccountEventUpdateBalance(
            accountId: event.fromAccountId,
            amountDelta: -event.amount,
          ),
        );
        accountBloc.add(
          AccountEventUpdateBalance(
            accountId: event.toAccountId,
            amountDelta: event.destinationAmount,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          for (final tx in newTransactions) {
            transactionRepository
                .addTransaction(tx)
                .then((_) {
                  add(TransactionEventMarkSynced(transactionId: tx.id));
                })
                .catchError((e) {
                  log('Cloud sync failed: $e');
                });
          }
        }
      } catch (e) {
        emit(
          state.copyWith(
            errorMessage: 'Transfer creation failed: ${e.toString()}',
          ),
        );
      }
    });

    on<TransactionEventUpdateTransaction>((event, emit) async {
      try {
        final updatedTransaction = event.transaction.copyWith(isSynced: false);
        final oldTransaction = state.transactionsList.firstWhere(
          (t) => t.id == updatedTransaction.id,
        );

        if (SystemCategoryIds.isBalanceAdjustment(oldTransaction.categoryId) &&
            updatedTransaction.transactionAmount !=
                oldTransaction.transactionAmount) {
          emit(
            state.copyWith(
              errorMessage: 'Cannot change amount of balance adjustment',
            ),
          );
          return;
        }

        final updatedList = state.transactionsList.map((transaction) {
          return transaction.id == updatedTransaction.id
              ? updatedTransaction
              : transaction;
        }).toList();

        _emitUpdatedState(
          emit,
          state.copyWith(transactionsList: updatedList, errorMessage: null),
        );
        categoryBloc.add(CategoryEventRefreshTotals(transactions: updatedList));

        // Update Account Balance
        // 1. Reverse old transaction effect
        if (oldTransaction.type == TransactionType.transfer) {
          if (oldTransaction.accountId.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: oldTransaction.accountId,
                amountDelta: oldTransaction.transactionAmount,
              ),
            );
          }
          if (oldTransaction.toAccountId != null &&
              oldTransaction.toAccountId!.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: oldTransaction.toAccountId!,
                amountDelta: -oldTransaction.transactionAmount,
              ),
            );
          }
        } else {
          final reversalDelta = oldTransaction.type == TransactionType.income
              ? -oldTransaction.transactionAmount
              : oldTransaction.transactionAmount;
          if (oldTransaction.accountId.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: oldTransaction.accountId,
                amountDelta: reversalDelta,
              ),
            );
          }
        }

        // 2. Apply new transaction effect
        final newAmountForAccount =
            event.convertedAmount ?? updatedTransaction.transactionAmount;
        if (updatedTransaction.type == TransactionType.transfer) {
          if (updatedTransaction.accountId.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: updatedTransaction.accountId,
                amountDelta: -newAmountForAccount,
              ),
            );
          }
          if (updatedTransaction.toAccountId != null &&
              updatedTransaction.toAccountId!.isNotEmpty) {
            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: updatedTransaction.toAccountId!,
                amountDelta: newAmountForAccount,
              ),
            );
          }
        } else {
          final newAmountDelta =
              updatedTransaction.type == TransactionType.income
              ? newAmountForAccount
              : -newAmountForAccount;
          if (updatedTransaction.accountId.isNotEmpty) {
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

        // Budget Warning Alert logic
        _checkBudgetLimit(
          transaction: updatedTransaction,
          updatedList: updatedList,
          toastCallback: event.toastCallback,
        );
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
        _emitUpdatedState(
          emit,
          state.copyWith(transactionsList: updatedList, errorMessage: null),
        );
        categoryBloc.add(CategoryEventRefreshTotals(transactions: updatedList));
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

        _emitUpdatedState(
          emit,
          state.copyWith(transactionsList: updatedList, errorMessage: null),
        );
        categoryBloc.add(CategoryEventRefreshTotals(transactions: updatedList));
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

        final idsToDelete = <String>{event.transactionId};
        if (transactionToDelete.isTransferLeg &&
            transactionToDelete.transferGroupId != null) {
          for (final t in state.transactionsList) {
            if (t.transferGroupId == transactionToDelete.transferGroupId &&
                t.id != event.transactionId) {
              idsToDelete.add(t.id);
            }
          }
        }

        final removedTransactions = state.transactionsList
            .where((t) => idsToDelete.contains(t.id))
            .toList();

        final updatedList = state.transactionsList
            .where((t) => !idsToDelete.contains(t.id))
            .toList();

        _emitUpdatedState(
          emit,
          state.copyWith(transactionsList: updatedList, errorMessage: null),
        );
        categoryBloc.add(CategoryEventRefreshTotals(transactions: updatedList));

        // Reverse Account Balance (skip for balance_adjustment only)
        if (!transactionToDelete.isBalanceAdjustment) {
          if (transactionToDelete.type == TransactionType.transfer) {
            if (transactionToDelete.accountId.isNotEmpty) {
              accountBloc.add(
                AccountEventUpdateBalance(
                  accountId: transactionToDelete.accountId,
                  amountDelta: transactionToDelete.transactionAmount,
                ),
              );
            }
            if (transactionToDelete.toAccountId != null &&
                transactionToDelete.toAccountId!.isNotEmpty) {
              accountBloc.add(
                AccountEventUpdateBalance(
                  accountId: transactionToDelete.toAccountId!,
                  amountDelta: -transactionToDelete.transactionAmount,
                ),
              );
            }
          } else {
            final reversalDelta =
                transactionToDelete.type == TransactionType.income
                ? -transactionToDelete.transactionAmount
                : transactionToDelete.transactionAmount;

            accountBloc.add(
              AccountEventUpdateBalance(
                accountId: transactionToDelete.accountId,
                amountDelta: reversalDelta,
              ),
            );
          }
        }

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          for (final id in idsToDelete) {
            await transactionRepository.deleteTransaction(id).catchError((e) {
              final restoredList = [
                ...removedTransactions,
                ...state.transactionsList,
              ];
              emit(
                state.copyWith(
                  transactionsList: restoredList,
                  errorMessage: 'Cloud delete failed. Will retry on next sync.',
                ),
              );
              categoryBloc.add(
                CategoryEventRefreshTotals(transactions: restoredList),
              );
              log('Failed to delete transaction $id: $e');
            });
          }
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
      // Check for duplicates based on sender, body, and timestamp
      final bool isDuplicate = state.pendingSmsTransactions.any(
        (existing) =>
            existing.sender == event.smsDraft.sender &&
            existing.body == event.smsDraft.body &&
            existing.timestamp == event.smsDraft.timestamp,
      );

      if (isDuplicate) {
        log("Duplicate SMS draft ignored: ${event.smsDraft.sender}");
        return;
      }

      final newDraft = event.smsDraft.copyWith(
        id: (event.smsDraft.id.isEmpty) ? const Uuid().v4() : event.smsDraft.id,
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
      add(
        TransactionEventCreateTransaction(
          event.transaction,
          toastCallback: event.toastCallback,
        ),
      );
    });

    on<TransactionEventDeclineSmsDraft>((event, emit) {
      final updatedDrafts = state.pendingSmsTransactions
          .where((draft) => draft.id != event.smsDraftId)
          .toList();
      emit(state.copyWith(pendingSmsTransactions: updatedDrafts));
    });

    on<TransactionEventUpdateSmsDraft>((event, emit) {
      final updatedDrafts = state.pendingSmsTransactions.map((draft) {
        return draft.id == event.updatedDraft.id ? event.updatedDraft : draft;
      }).toList();
      emit(state.copyWith(pendingSmsTransactions: updatedDrafts));
    });

    on<TransactionEventSelectAccount>((event, emit) {
      final newState = _calculateAccountDetails(
        accountId: event.accountId,
        transactions: state.transactionsList,
        currentState: state,
      );
      emit(newState.copyWith(selectedAccountId: event.accountId));
    });

    on<TransactionEventBulkCreate>((event, emit) async {
      try {
        final userId = authRepository.currentUser?.uid ?? '';
        if (event.transactions.isEmpty) {
          event.completer?.complete();
          return;
        }

        final List<TransactionModel> newTransactions = [];

        for (var tx in event.transactions) {
          newTransactions.add(
            tx.copyWith(
              id: tx.id.isEmpty ? const Uuid().v4() : tx.id,
              userId: userId,
              isSynced: false,
            ),
          );
        }

        final updatedList = [...newTransactions, ...state.transactionsList];

        _emitUpdatedState(
          emit,
          state.copyWith(transactionsList: updatedList, errorMessage: null),
        );
        categoryBloc.add(CategoryEventRefreshTotals(transactions: updatedList));

        // Update Account Balances in Bulk
        final Map<String, double> balanceChanges = {};
        for (var tx in newTransactions) {
          if (tx.accountId.isNotEmpty) {
            final delta = tx.type == TransactionType.income
                ? tx.transactionAmount
                : -tx.transactionAmount;
            balanceChanges[tx.accountId] =
                (balanceChanges[tx.accountId] ?? 0.0) + delta;
          }
        }

        balanceChanges.forEach((accountId, delta) {
          accountBloc.add(
            AccountEventUpdateBalance(accountId: accountId, amountDelta: delta),
          );
        });

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          final syncedTransactions = newTransactions
              .map((transaction) => transaction.copyWith(isSynced: true))
              .toList();
          await transactionRepository.bulkAddTransactions(syncedTransactions);
          // Mark all as synced
          final syncedIds = syncedTransactions.map((t) => t.id).toSet();
          final listAfterSync = updatedList.map((t) {
            if (syncedIds.contains(t.id)) {
              return t.copyWith(isSynced: true);
            }
            return t;
          }).toList();
          _emitUpdatedState(
            emit,
            state.copyWith(transactionsList: listAfterSync),
          );
          categoryBloc.add(
            CategoryEventRefreshTotals(transactions: listAfterSync),
          );
        }

        event.completer?.complete();
      } catch (e) {
        event.completer?.completeError(e);
        emit(
          state.copyWith(errorMessage: 'Bulk import failed: ${e.toString()}'),
        );
      }
    });

    on<TransactionEventLoadBackgroundDrafts>((event, emit) async {
      emit(state.copyWith(isProcessingBackgroundDrafts: true));
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final List<String>? draftsJson = prefs.getStringList(
          'pending_background_drafts',
        );

        if (draftsJson != null && draftsJson.isNotEmpty) {
          await prefs.remove('pending_background_drafts');

          final List<SmsDraftModel> newDrafts = draftsJson
              .map((jsonStr) => SmsDraftModel.fromJson(jsonStr))
              .toList();

          // Merge with existing pending transactions, avoiding duplicates
          final currentPending = List<SmsDraftModel>.from(
            state.pendingSmsTransactions,
          );
          for (final draft in newDrafts) {
            if (!currentPending.any((existing) => existing.id == draft.id)) {
              currentPending.insert(0, draft);
            }
          }

          emit(
            state.copyWith(
              pendingSmsTransactions: currentPending,
              isProcessingBackgroundDrafts: false,
            ),
          );
        } else {
          emit(state.copyWith(isProcessingBackgroundDrafts: false));
        }
      } catch (e) {
        log("Error loading background drafts in BLoC: $e");
        emit(state.copyWith(isProcessingBackgroundDrafts: false));
      }
    });
  }

  TransactionState _calculateAccountDetails({
    required String? accountId,
    required List<TransactionModel> transactions,
    required TransactionState currentState,
  }) {
    if (accountId == null || accountId.isEmpty) {
      return currentState.copyWith(
        recentTransactions: [],
        currentAccountBalance: 0.0,
      );
    }

    final accountTransactions = transactions
        .where((t) => t.accountId == accountId)
        .toList();

    final recent = accountTransactions.take(5).toList();

    final balance = accountTransactions.fold<double>(0.0, (sum, t) {
      return sum +
          (t.type == TransactionType.income
              ? t.transactionAmount
              : -t.transactionAmount);
    });

    DateTime? lastUpdated;
    if (accountTransactions.isNotEmpty) {
      lastUpdated = accountTransactions
          .map((t) => t.updatedAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    return currentState.copyWith(
      recentTransactions: recent,
      currentAccountBalance: balance,
      lastAccountUpdatedAt: lastUpdated,
    );
  }

  void _emitUpdatedState(
    Emitter<TransactionState> emit,
    TransactionState newState,
  ) {
    final stateWithDetails = _calculateAccountDetails(
      accountId: newState.selectedAccountId,
      transactions: newState.transactionsList,
      currentState: newState,
    );
    emit(stateWithDetails);
  }

  void _checkBudgetLimit({
    required TransactionModel transaction,
    required List<TransactionModel> updatedList,
    required VoidCallback toastCallback,
  }) {
    try {
      final category = categoryBloc.state.categoriesList
          .where((c) => c.id == transaction.categoryId)
          .firstOrNull;

      if (category != null &&
          category.hasBudgetAmount &&
          category.budgetAmount != null) {
        final now = DateTime.now();
        final categoryTotal = updatedList
            .where(
              (t) =>
                  t.categoryId == transaction.categoryId &&
                  t.type == TransactionType.expense &&
                  t.transactionDate.month == now.month &&
                  t.transactionDate.year == now.year,
            )
            .fold(0.0, (sum, t) => sum + t.transactionAmount);

        if (settingsBloc.state.model.allNotificationsEnabled &&
            settingsBloc.state.model.categoryBudgetNotificationsEnabled) {
          if (categoryTotal >= category.budgetAmount!) {
            toastCallback();
          }
        }
      }
    } catch (e) {
      log('Failed to check budget warning: $e');
    }
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
