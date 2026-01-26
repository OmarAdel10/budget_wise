import 'dart:developer';

import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/accounts/data/repositories/account_repository.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_state.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

class AccountBloc extends HydratedBloc<AccountEvent, AccountState> {
  final SettingsBloc settingsBloc;
  final AccountRepository accountRepo;
  AccountBloc({required this.settingsBloc, required this.accountRepo})
    : super(AccountStateInitial(accountsList: [], netWorth: 0)) {
    on<AccountEventFetchAll>((event, emit) async {
      if (settingsBloc.state.model.hasLoggedIn) {
        try {
          final accounts = await accountRepo.fetchAllAccounts();
          emit(
            AccountStateSuccess(
              accountsList: accounts,
              netWorth: state.netWorth,
            ),
          );
        } catch (e) {
          log('Failed to fetch accounts: ${e.toString()}');
          emit(
            AccountStateError(
              message: 'Failed to fetch accounts: ${e.toString()}',
              accountsList: state.accountsList,
              netWorth: state.netWorth,
            ),
          );
        }
      }
    });

    on<AccountEventCreateAccount>((event, emit) {
      final user = accountRepo.authRepo.currentUser;
      try {
        final newAccount = event.model
          ..id = const Uuid().v4()
          ..userId = user != null ? user.uid : ''
          ..isSynced = false;

        final isDuplicate = state.accountsList.any(
          (account) =>
              account.title.toLowerCase() == newAccount.title.toLowerCase() &&
              account.accountType == newAccount.accountType,
        );

        if (isDuplicate) return;
        final updatedList = [newAccount, ...state.accountsList];
        emit(
          AccountStateSuccess(
            accountsList: updatedList,
            netWorth: state.netWorth + newAccount.initialBalance,
          ),
        );
        if (settingsBloc.state.model.hasLoggedIn) {
          accountRepo
              .addAccount(newAccount)
              .then(
                (_) => add(AccountEventMarkSynced(accountId: newAccount.id)),
              )
              .catchError((e) {
                log('Cloud sync failed(create method): ${e.toString()}');
                emit(
                  AccountStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    accountsList: state.accountsList,
                    netWorth: state.netWorth,
                  ),
                );
              });
        }
      } catch (e) {
        log('Failed to create new account: ${e.toString()}');
        emit(
          AccountStateError(
            message: 'Failed to create new account: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });

    on<AccountEventEditAccount>((event, emit) {
      try {
        final updatedAccount = event.model;
        final oldAccount = state.accountsList.firstWhere(
          (account) => account.id == updatedAccount.id,
        );
        final balanceDelta = updatedAccount.balance - oldAccount.balance;

        final updatedList = state.accountsList
            .map(
              (account) =>
                  account.id == updatedAccount.id ? updatedAccount : account,
            )
            .toList();
        emit(
          AccountStateSuccess(
            accountsList: updatedList,
            netWorth: state.netWorth + balanceDelta,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn) {
          accountRepo
              .addAccount(updatedAccount)
              .then(
                (_) =>
                    add(AccountEventMarkSynced(accountId: updatedAccount.id)),
              )
              .catchError((e) {
                log('Cloud sync failed(update method): ${e.toString()}');
                emit(
                  AccountStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    accountsList: state.accountsList,
                    netWorth: state.netWorth,
                  ),
                );
              });
        }
      } catch (e) {
        log('Failed to update account: ${e.toString()}');
        emit(
          AccountStateError(
            message: 'Failed to update account: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });

    on<AccountEventUpdateUpdatedAtField>((event, emit) {
      try {
        final updatedAccountId = event.accountId;
        final updatedList = state.accountsList
            .map(
              (account) => account.id == updatedAccountId
                  ? account.copyWith(updatedAt: event.updateDate)
                  : account,
            )
            .toList();
        emit(
          AccountStateSuccess(
            accountsList: updatedList,
            netWorth: state.netWorth,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn) {
          accountRepo
              .updateAccountUpdatedAt(updatedAccountId, event.updateDate)
              .then(
                (_) => add(AccountEventMarkSynced(accountId: updatedAccountId)),
              )
              .catchError((e) {
                log('Cloud sync failed(update method): ${e.toString()}');
                emit(
                  AccountStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    accountsList: state.accountsList,
                    netWorth: state.netWorth,
                  ),
                );
              });
        }
      } catch (e) {
        log('Failed to update account: ${e.toString()}');
        emit(
          AccountStateError(
            message: 'Failed to update account: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });

    on<AccountEventDeleteAccount>((event, emit) {
      try {
        final accountToDelete = state.accountsList.firstWhere(
          (account) => account.id == event.accountId,
        );
        final updatedList = state.accountsList
            .where((account) => account.id != event.accountId)
            .toList();
        emit(
          AccountStateSuccess(
            accountsList: updatedList,
            netWorth: state.netWorth - accountToDelete.balance,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn) {
          accountRepo.deleteAccount(event.accountId).catchError((e) {
            log('Cloud sync failed(delete method): ${e.toString()}');
            emit(
              AccountStateError(
                message: 'Cloud sync failed: ${e.toString()}',
                accountsList: state.accountsList,
                netWorth: state.netWorth,
              ),
            );
          });
        }
      } catch (e) {
        log('Failed to delete account: ${e.toString()}');
        emit(
          AccountStateError(
            message: 'Failed to delete account: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });

    on<AccountEventMarkSynced>((event, emit) {
      try {
        final updatedList = state.accountsList
            .map(
              (account) => account.id == event.accountId
                  ? account.copyWith(isSynced: true)
                  : account,
            )
            .toList();
        emit(
          AccountStateSuccess(
            accountsList: updatedList,
            netWorth: state.netWorth,
          ),
        );
      } catch (e) {
        log('Failed to mark account synced: ${e.toString()}');
        emit(
          AccountStateError(
            message: 'Failed to mark account synced: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });

    on<AccountEventSyncUnsynced>((event, emit) async {
      try {
        final unSynced = state.accountsList
            .where((account) => account.isSynced == false)
            .toList();
        if (unSynced.isEmpty) return;

        final synced = unSynced
            .map(
              (unSyncedAccount) => accountRepo
                  .addAccount(unSyncedAccount)
                  .then(
                    (e) => add(
                      AccountEventMarkSynced(accountId: unSyncedAccount.id),
                    ),
                  )
                  .catchError((e) {
                    log('Cloud sync failed(delete method): ${e.toString()}');
                    emit(
                      AccountStateError(
                        message: 'Cloud sync failed: ${e.toString()}',
                        accountsList: state.accountsList,
                        netWorth: state.netWorth,
                      ),
                    );
                  }),
            )
            .toList();
        await Future.wait(synced);
      } catch (e) {
        log('Failed to sync the unsynced account: ${e.toString()}');
        emit(
          AccountStateError(
            message: 'Failed to sync the unsynced account: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });

    on<AccountEventUpdateBalance>((event, emit) {
      try {
        final updatedList = state.accountsList.map((account) {
          if (account.id == event.accountId) {
            return account.copyWith(
              balance: account.balance + event.amountDelta,
              updatedAt: DateTime.now(),
            );
          }
          return account;
        }).toList();

        final updatedAccount = updatedList.firstWhere(
          (account) => account.id == event.accountId,
        );

        emit(
          AccountStateSuccess(
            accountsList: updatedList,
            netWorth: state.netWorth + event.amountDelta,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn) {
          accountRepo
              .updateAccountBalance(
                updatedAccount.id,
                updatedAccount.balance,
                updatedAccount.updatedAt,
              )
              .then(
                (_) =>
                    add(AccountEventMarkSynced(accountId: updatedAccount.id)),
              )
              .catchError((e) {
                log(
                  'Cloud sync failed(update balance method): ${e.toString()}',
                );
                emit(
                  AccountStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    accountsList: state.accountsList,
                    netWorth: state.netWorth,
                  ),
                );
              });
        }
      } catch (e) {
        log('Failed to update account balance: ${e.toString()}');
        emit(
          AccountStateError(
            message: 'Failed to update account balance: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });

    on<AccountEventSyncPendingOnLogin>((event, emit) async {
      try {
        final pendingAccounts = state.accountsList
            .where(
              (account) =>
                  account.isSynced == false &&
                  accountRepo.authRepo.currentUser != null,
            )
            .toList();
        if (pendingAccounts.isEmpty) return;
        for (var account in pendingAccounts) {
          final accountWithUserId = account.copyWith(
            userId: accountRepo.authRepo.currentUser!.uid,
          );
          await accountRepo
              .addAccount(accountWithUserId)
              .then(
                (_) => add(
                  AccountEventMarkSynced(accountId: accountWithUserId.id),
                ),
              )
              .catchError((e) {
                log('Failed to sync account ${account.id} on login: $e');
              });
        }
      } catch (e) {
        emit(
          AccountStateError(
            message: 'Sync on login failed: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });

    on<AccountEventCheckAndSyncPending>((event, emit) async {
      try {
        if (accountRepo.authRepo.currentUser == null) return;

        final pendingAccounts = state.accountsList
            .where((a) => a.isSynced == false)
            .toList();
        if (pendingAccounts.isEmpty) return;
        for (var account in pendingAccounts) {
          await accountRepo
              .addAccount(account)
              .then((_) => add(AccountEventMarkSynced(accountId: account.id)))
              .catchError((e) {
                log('Failed to sync account ${account.id}: $e');
              });
        }
      } catch (e) {
        emit(
          AccountStateError(
            message: 'Check and sync failed: ${e.toString()}',
            accountsList: state.accountsList,
            netWorth: state.netWorth,
          ),
        );
      }
    });
  }

  @override
  AccountState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic>? list = json['accountsList'];
      final netWorth = json['netWorth'];

      if (list == null || netWorth == null) {
        return const AccountStateSuccess(accountsList: [], netWorth: 0);
      }
      final List<AccountModel> accountsList = list
          .map((e) => AccountModel.fromMap(e))
          .toList();
      return AccountStateSuccess(
        accountsList: accountsList,
        netWorth: netWorth,
      );
    } catch (e) {
      log('Error During Serialization: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AccountState state) {
    return {
      'accountsList': state.accountsList
          .map((account) => account.toMap())
          .toList(),
      'netWorth': state.netWorth,
    };
  }
}
