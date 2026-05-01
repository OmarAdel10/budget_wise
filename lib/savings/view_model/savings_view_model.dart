import 'dart:developer';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/data/repositories/savings_repository.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/savings/view_model/savings_state.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

class SavingsBloc extends HydratedBloc<SavingsEvent, SavingsState> {
  final SettingsBloc settingsBloc;
  final SavingsRepository savingsRepo;
  final AuthRepository authRepository;
  final AccountBloc accountBloc;

  SavingsBloc({
    required this.settingsBloc,
    required this.savingsRepo,
    required this.authRepository,
    required this.accountBloc,
  }) : super(const SavingsStateInitial(savingsList: [])) {
    authRepository.authStateChanges.listen((user) {
      if (user != null && settingsBloc.state.model.hasLoggedIn) {
        add(const SavingsEventFetchAll());
      }
    });

    settingsBloc.stream.listen((settingsState) {
      final isEnabled =
          settingsState.model.allNotificationsEnabled &&
          settingsState.model.savingsNotificationsEnabled;
      if (isEnabled) {
        for (var goal in state.savingsList) {
          _scheduleNotifications(goal);
        }
      } else {
        for (var goal in state.savingsList) {
          _cancelNotifications(goal);
        }
      }
    });

    on<SavingsEventFetchAll>((event, emit) async {
      try {
        final remoteGoals = await savingsRepo.fetchAllSavingGoals();
        final localGoalsMap = {
          for (final goal in state.savingsList) goal.id: goal,
        };
        final updatedList = <SavingsModel>[];

        for (final remoteItem in remoteGoals) {
          final localItem = localGoalsMap[remoteItem.id];

          if (localItem == null) {
            updatedList.add(remoteItem);
            _scheduleNotifications(remoteItem);
          } else {
            if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
              updatedList.add(remoteItem);
              _scheduleNotifications(remoteItem);
            } else {
              updatedList.add(localItem);
            }
          }
          localGoalsMap.remove(remoteItem.id);
        }
        updatedList.addAll(localGoalsMap.values);

        _syncToSharedPreferences(updatedList);
        emit(SavingsStateSuccess(savingsList: updatedList));
      } catch (e) {
        log('Failed to fetch saving goals: ${e.toString()}');
        emit(
          SavingsStateError(
            message: 'Failed to fetch saving goals: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<SavingsEventCreateGoal>((event, emit) async {
      final user = authRepository.currentUser;
      try {
        final newGoal = event.model.copyWith(
          id: event.model.id.isEmpty ? const Uuid().v4() : event.model.id,
          userId: user != null ? user.uid : '',
          isSynced: false,
        );

        if (settingsBloc.state.model.hasLoggedIn) {
          await savingsRepo.createGoalWithAccount(newGoal);
          add(const SavingsEventFetchAll());
        } else {
          final updatedList = [...state.savingsList, newGoal];
          _scheduleNotifications(newGoal);
          _syncToSharedPreferences(updatedList);
          emit(SavingsStateSuccess(savingsList: updatedList));
        }
      } catch (e) {
        log('Failed to create saving goal: ${e.toString()}');
        emit(
          SavingsStateError(
            message: 'Failed to create saving goal: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<SavingsEventEditGoal>((event, emit) {
      try {
        final updatedGoal = event.model.copyWith(
          updatedAt: DateTime.now(),
          isSynced: false,
        );
        final updatedList = state.savingsList
            .map((goal) => goal.id == updatedGoal.id ? updatedGoal : goal)
            .toList();

        _cancelNotifications(updatedGoal);
        _scheduleNotifications(updatedGoal);

        _syncToSharedPreferences(updatedList);
        emit(SavingsStateSuccess(savingsList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn) {
          savingsRepo
              .updateSavingGoal(updatedGoal)
              .then((_) => add(SavingsEventMarkSynced(goalId: updatedGoal.id)))
              .catchError((e) {
                log('Cloud sync failed(edit goal): ${e.toString()}');
                emit(
                  SavingsStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    savingsList: state.savingsList,
                  ),
                );
              });
        }
      } catch (e) {
        log('Failed to edit saving goal: ${e.toString()}');
        emit(
          SavingsStateError(
            message: 'Failed to edit saving goal: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<SavingsEventDeleteGoal>((event, emit) {
      try {
        final goal = state.savingsList.firstWhere((g) => g.id == event.goalId);
        _cancelNotifications(goal);

        final updatedList = state.savingsList
            .where((goal) => goal.id != event.goalId)
            .toList();
        _syncToSharedPreferences(updatedList);
        emit(SavingsStateSuccess(savingsList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn) {
          savingsRepo.deleteSavingGoal(event.goalId).catchError((e) {
            log('Cloud sync failed(delete goal): ${e.toString()}');
            emit(
              SavingsStateError(
                message: 'Cloud sync failed: ${e.toString()}',
                savingsList: state.savingsList,
              ),
            );
          });
        }
      } catch (e) {
        log('Failed to delete saving goal: ${e.toString()}');
        emit(
          SavingsStateError(
            message: 'Failed to delete saving goal: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<SavingsEventToggleDayContribution>((event, emit) async {
      try {
        final goal = state.savingsList.firstWhere((g) => g.id == event.goalId);
        final bool isCompleting = !goal.completedDays.contains(event.day);
        final bool wasCompletedBefore = goal.isCompleted;

        if (isCompleting) {
          final amount = goal.getAmountForDay(event.day);
          final sourceAccount = accountBloc.state.accountsList.firstWhere(
            (a) => a.id == goal.sourceAccountId,
          );
          final savingAccount = accountBloc.state.accountsList.firstWhere(
            (a) => a.id == goal.savingAccountId,
          );

          if (sourceAccount.balance < amount) {
            emit(
              SavingsStateError(
                message: 'insufficient_funds',
                savingsList: state.savingsList,
              ),
            );
            return;
          }

          if (settingsBloc.state.model.hasLoggedIn) {
            await savingsRepo.processContribution(
              goal: goal,
              day: event.day,
              amount: amount,
              sourceAccount: sourceAccount,
              savingAccount: savingAccount,
            );
            accountBloc.add(const AccountEventFetchAll());
            
            final remoteGoals = await savingsRepo.fetchAllSavingGoals();
            final updatedGoal = remoteGoals.firstWhere((g) => g.id == goal.id);
            final bool nowCompleted = updatedGoal.isCompleted;

            emit(SavingsStateSuccess(
              savingsList: remoteGoals,
              showCompletionToast: !wasCompletedBefore && nowCompleted,
              completedGoalName: updatedGoal.name,
            ));
          }
        }
      } catch (e) {
        log('Failed to toggle contribution: ${e.toString()}');
        emit(
          SavingsStateError(
            message: 'Failed to toggle contribution: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<SavingsEventUpdateCustomAmount>((event, emit) {
      try {
        final goal = state.savingsList.firstWhere((g) => g.id == event.goalId);
        final bool wasCompletedBefore = goal.isCompleted;

        final updatedList = state.savingsList.map((goal) {
          if (goal.id == event.goalId) {
            final Map<int, double> updatedCustomAmounts = Map.from(
              goal.customAmounts,
            );
            final List<int> updatedDays = List.from(goal.completedDays);
            final Map<int, DateTime> updatedDates = Map.from(
              goal.contributionDates,
            );
            double newAmount = goal.currentAmount;

            if (updatedCustomAmounts.containsKey(event.day)) {
              newAmount -= updatedCustomAmounts[event.day]!;
            }

            updatedCustomAmounts[event.day] = event.amount;
            newAmount += event.amount;

            if (event.amount > 0 && !updatedDays.contains(event.day)) {
              updatedDays.add(event.day);
              updatedDates[event.day] = DateTime.now();
            } else if (event.amount <= 0) {
              updatedDays.remove(event.day);
              updatedDates.remove(event.day);
            }

            return goal.copyWith(
              customAmounts: updatedCustomAmounts,
              completedDays: updatedDays,
              contributionDates: updatedDates,
              currentAmount: newAmount,
              updatedAt: DateTime.now(),
              isSynced: false,
            );
          }
          return goal;
        }).toList();

        final updatedGoal = updatedList.firstWhere(
          (goal) => goal.id == event.goalId,
        );
        final bool nowCompleted = updatedGoal.isCompleted;

        _syncToSharedPreferences(updatedList);
        emit(SavingsStateSuccess(
          savingsList: updatedList,
          showCompletionToast: !wasCompletedBefore && nowCompleted,
          completedGoalName: updatedGoal.name,
        ));

        if (settingsBloc.state.model.hasLoggedIn) {
          savingsRepo
              .updateContribution(
                updatedGoal.id,
                updatedGoal.currentAmount,
                updatedGoal.completedDays,
                updatedGoal.contributionDates,
                updatedGoal.customAmounts,
                updatedGoal.updatedAt,
              )
              .then((_) => add(SavingsEventMarkSynced(goalId: updatedGoal.id)))
              .catchError((e) {
                log('Cloud sync failed(update custom): ${e.toString()}');
                emit(
                  SavingsStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    savingsList: state.savingsList,
                  ),
                );
              });
        }
      } catch (e) {
        log('Failed to update custom amount: ${e.toString()}');
        emit(
          SavingsStateError(
            message: 'Failed to update custom amount: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<SavingsEventMarkSynced>((event, emit) {
      final updatedList = state.savingsList
          .map(
            (goal) =>
                goal.id == event.goalId ? goal.copyWith(isSynced: true) : goal,
          )
          .toList();
      _syncToSharedPreferences(updatedList);
      emit(SavingsStateSuccess(savingsList: updatedList));
    });

    on<SavingsEventSyncPendingOnLogin>((event, emit) async {
      final pendingGoals = state.savingsList
          .where(
            (goal) =>
                goal.isSynced == false && authRepository.currentUser != null,
          )
          .toList();
      if (pendingGoals.isEmpty) return;

      for (var goal in pendingGoals) {
        final goalWithUserId = goal.copyWith(
          userId: authRepository.currentUser!.uid,
        );
        await savingsRepo
            .addSavingGoal(goalWithUserId)
            .then((_) => add(SavingsEventMarkSynced(goalId: goalWithUserId.id)))
            .catchError(
              (e) => log('Failed to sync goal ${goal.id} on login: $e'),
            );
      }
      _syncToSharedPreferences(state.savingsList);
    });

    on<SavingsEventCheckAndSyncPending>((event, emit) async {
      if (authRepository.currentUser == null) return;
      final pendingGoals = state.savingsList
          .where((goal) => goal.isSynced == false)
          .toList();
      if (pendingGoals.isEmpty) return;

      for (var goal in pendingGoals) {
        await savingsRepo
            .addSavingGoal(goal)
            .then((_) => add(SavingsEventMarkSynced(goalId: goal.id)))
            .catchError((e) => log('Failed to sync goal ${goal.id}: $e'));
      }
      _syncToSharedPreferences(state.savingsList);
    });

    on<SavingsEventBulkCreate>((event, emit) async {
      try {
        if (event.goals.isEmpty) {
          event.completer?.complete();
          return;
        }

        final userId = authRepository.currentUser?.uid ?? '';
        final normalizedGoals = <SavingsModel>[];
        final seenKeys = <String>{};

        for (final goal in event.goals) {
          final normalized = goal.copyWith(
            id: goal.id.isEmpty ? const Uuid().v4() : goal.id,
            userId: userId,
            isSynced: false,
          );

          if (seenKeys.add(_savingsImportKey(normalized))) {
            normalizedGoals.add(normalized);
          }
        }

        if (normalizedGoals.isEmpty) {
          event.completer?.complete();
          return;
        }

        final updatedList = [...normalizedGoals, ...state.savingsList];
        for (final goal in normalizedGoals) {
          _scheduleNotifications(goal);
        }

        _syncToSharedPreferences(updatedList);
        emit(SavingsStateSuccess(savingsList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          final syncedGoals = normalizedGoals
              .map((goal) => goal.copyWith(isSynced: true))
              .toList();
          final persistedGoals = await savingsRepo.bulkCreateGoalsWithAccounts(
            syncedGoals,
          );

          final persistedById = {
            for (final goal in persistedGoals)
              goal.id: goal.copyWith(isSynced: true),
          };
          final finalList = updatedList.map((goal) {
            return persistedById[goal.id] ?? goal;
          }).toList();

          _syncToSharedPreferences(finalList);
          emit(SavingsStateSuccess(savingsList: finalList));
        }

        event.completer?.complete();
      } catch (e) {
        event.completer?.completeError(e);
        log('Failed to bulk import savings goals: ${e.toString()}');
        emit(
          SavingsStateError(
            message: 'Failed to bulk import savings goals: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });
  }

  void _syncToSharedPreferences(List<SavingsModel> savings) {
    final List<Map<String, dynamic>> mapList =
        savings.map((s) => s.toMap()).toList();
    settingsBloc.add(SettingsEventSyncSavingsSnapshot(mapList));
  }

  String _savingsImportKey(SavingsModel goal) {
    return [
      goal.name.toLowerCase(),
      goal.currency.toLowerCase(),
      goal.sourceAccountId.toLowerCase(),
    ].join('|');
  }

  void _scheduleNotifications(SavingsModel goal) async {
    final isEnabled =
        settingsBloc.state.model.allNotificationsEnabled &&
        settingsBloc.state.model.savingsNotificationsEnabled;
    if (!isEnabled) return;

    final baseId = goal.id.hashCode.abs();

    // 1. Mid-day reminder (2:00 PM) for the next 7 days
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final scheduledDate = DateTime(date.year, date.month, date.day, 14, 0);

      if (scheduledDate.isAfter(now)) {
        await NotificationRepository.scheduledNotification(
          channelId: 'saving_alerts',
          channelName: 'Savings Alerts',
          channelDescription: 'Alerts for savings goals',
          id: baseId + i,
          title: 'Daily Saving Reminder',
          body: "Don't forget to save for your '${goal.name}' goal today!",
          scheduledDate: scheduledDate,
          payload: 'saving_goal_${goal.id}',
        );
      }
    }

    // 2. Deadline reminder
    if (goal.targetDate.isAfter(now)) {
      await NotificationRepository.scheduledNotification(
        channelId: 'saving_alerts',
        channelName: 'Savings Alerts',
        channelDescription: 'Alerts for savings goals',
        id: baseId + 100,
        title: 'Savings Goal Deadline',
        body:
            "Today is the deadline for your '${goal.name}' goal. Check your progress!",
        scheduledDate: goal.targetDate,
        payload: 'saving_goal_${goal.id}',
      );
    }
  }

  void _cancelNotifications(SavingsModel goal) async {
    final baseId = goal.id.hashCode.abs();
    for (int i = 0; i < 7; i++) {
      await NotificationRepository.cancelNotificationById(baseId + i);
    }
    await NotificationRepository.cancelNotificationById(baseId + 100);
  }

  @override
  SavingsState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic>? list = json['savingsList'];
      if (list == null) {
        return const SavingsStateSuccess(savingsList: []);
      }
      final List<SavingsModel> savingsList = list
          .map((e) => SavingsModel.fromMap(e))
          .toList();

      // Mirror to Snapshot on load
      _syncToSharedPreferences(savingsList);

      return SavingsStateSuccess(savingsList: savingsList);
    } catch (e) {
      log('Error During Savings Serialization: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SavingsState state) {
    return {
      'savingsList': state.savingsList.map((goal) => goal.toMap()).toList(),
    };
  }
}
