import 'dart:developer';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:budget_wise/buckets/data/repositories/saving_goal_repository.dart';
import 'package:budget_wise/buckets/view_model/buckets_event.dart';
import 'package:budget_wise/buckets/view_model/buckets_state.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

class BucketsBloc extends HydratedBloc<BucketsEvent, BucketsState> {
  final SettingsBloc settingsBloc;
  final SavingGoalRepository savingGoalRepo;
  final AuthRepository authRepository;
  final AccountBloc accountBloc;

  BucketsBloc({
    required this.settingsBloc,
    required this.savingGoalRepo,
    required this.authRepository,
    required this.accountBloc,
  }) : super(const BucketsStateInitial(savingsList: [])) {
    authRepository.authStateChanges.listen((user) {
      if (user != null && settingsBloc.state.model.hasLoggedIn) {
        add(const BucketsEventFetchAll());
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

    on<BucketsEventFetchAll>((event, emit) async {
      try {
        final remoteGoals = await savingGoalRepo.fetchAllSavingGoals();
        final localGoalsMap = {
          for (final goal in state.savingsList) goal.id: goal,
        };
        final updatedList = <SavingGoalModel>[];

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
        emit(BucketsStateSuccess(savingsList: updatedList));
      } catch (e) {
        log('Failed to fetch saving goals: ${e.toString()}');
        emit(
          BucketsStateError(
            message: 'Failed to fetch saving goals: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<BucketsEventCreateGoal>((event, emit) async {
      final user = authRepository.currentUser;
      try {
        final newGoal = event.model.copyWith(
          id: event.model.id.isEmpty ? const Uuid().v4() : event.model.id,
          userId: user != null ? user.uid : '',
          isSynced: false,
        );

        if (settingsBloc.state.model.hasLoggedIn) {
          await savingGoalRepo.createGoalWithAccount(newGoal);
          add(const BucketsEventFetchAll());
        } else {
          final updatedList = [...state.savingsList, newGoal];
          _scheduleNotifications(newGoal);
          _syncToSharedPreferences(updatedList);
          emit(BucketsStateSuccess(savingsList: updatedList));
        }
      } catch (e) {
        log('Failed to create saving goal: ${e.toString()}');
        emit(
          BucketsStateError(
            message: 'Failed to create saving goal: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<BucketsEventEditGoal>((event, emit) {
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
        emit(BucketsStateSuccess(savingsList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn) {
          savingGoalRepo
              .updateSavingGoal(updatedGoal)
              .then((_) => add(BucketsEventMarkSynced(goalId: updatedGoal.id)))
              .catchError((e) {
                log('Cloud sync failed(edit goal): ${e.toString()}');
                emit(
                  BucketsStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    savingsList: state.savingsList,
                  ),
                );
              });
        }
      } catch (e) {
        log('Failed to edit saving goal: ${e.toString()}');
        emit(
          BucketsStateError(
            message: 'Failed to edit saving goal: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<BucketsEventDeleteGoal>((event, emit) {
      try {
        final goal = state.savingsList.firstWhere((g) => g.id == event.goalId);
        _cancelNotifications(goal);

        final updatedList = state.savingsList
            .where((goal) => goal.id != event.goalId)
            .toList();
        _syncToSharedPreferences(updatedList);
        emit(BucketsStateSuccess(savingsList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn) {
          savingGoalRepo.deleteSavingGoal(event.goalId).catchError((e) {
            log('Cloud sync failed(delete goal): ${e.toString()}');
            emit(
              BucketsStateError(
                message: 'Cloud sync failed: ${e.toString()}',
                savingsList: state.savingsList,
              ),
            );
          });
        }
      } catch (e) {
        log('Failed to delete saving goal: ${e.toString()}');
        emit(
          BucketsStateError(
            message: 'Failed to delete saving goal: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<BucketsEventToggleDayContribution>((event, emit) async {
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
              BucketsStateError(
                message: 'insufficient_funds',
                savingsList: state.savingsList,
              ),
            );
            return;
          }

          if (settingsBloc.state.model.hasLoggedIn) {
            await savingGoalRepo.processContribution(
              goal: goal,
              day: event.day,
              amount: amount,
              sourceAccount: sourceAccount,
              savingAccount: savingAccount,
            );
            accountBloc.add(const AccountEventFetchAll());

            final remoteGoals = await savingGoalRepo.fetchAllSavingGoals();
            final updatedGoal = remoteGoals.firstWhere((g) => g.id == goal.id);
            final bool nowCompleted = updatedGoal.isCompleted;

            emit(
              BucketsStateSuccess(
                savingsList: remoteGoals,
                showCompletionToast: !wasCompletedBefore && nowCompleted,
                completedGoalName: updatedGoal.name,
              ),
            );
          }
        }
      } catch (e) {
        log('Failed to toggle contribution: ${e.toString()}');
        emit(
          BucketsStateError(
            message: 'Failed to toggle contribution: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<BucketsEventUpdateCustomAmount>((event, emit) {
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
        emit(
          BucketsStateSuccess(
            savingsList: updatedList,
            showCompletionToast: !wasCompletedBefore && nowCompleted,
            completedGoalName: updatedGoal.name,
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn) {
          savingGoalRepo
              .updateContribution(
                updatedGoal.id,
                updatedGoal.currentAmount,
                updatedGoal.completedDays,
                updatedGoal.contributionDates,
                updatedGoal.customAmounts,
                updatedGoal.updatedAt,
              )
              .then((_) => add(BucketsEventMarkSynced(goalId: updatedGoal.id)))
              .catchError((e) {
                log('Cloud sync failed(update custom): ${e.toString()}');
                emit(
                  BucketsStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    savingsList: state.savingsList,
                  ),
                );
              });
        }
      } catch (e) {
        log('Failed to update custom amount: ${e.toString()}');
        emit(
          BucketsStateError(
            message: 'Failed to update custom amount: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });

    on<BucketsEventMarkSynced>((event, emit) {
      final updatedList = state.savingsList
          .map(
            (goal) =>
                goal.id == event.goalId ? goal.copyWith(isSynced: true) : goal,
          )
          .toList();
      _syncToSharedPreferences(updatedList);
      emit(BucketsStateSuccess(savingsList: updatedList));
    });

    on<BucketsEventSyncPendingOnLogin>((event, emit) async {
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
        await savingGoalRepo
            .addSavingGoal(goalWithUserId)
            .then((_) => add(BucketsEventMarkSynced(goalId: goalWithUserId.id)))
            .catchError(
              (e) => log('Failed to sync goal ${goal.id} on login: $e'),
            );
      }
      _syncToSharedPreferences(state.savingsList);
    });

    on<BucketsEventCheckAndSyncPending>((event, emit) async {
      if (authRepository.currentUser == null) return;
      final pendingGoals = state.savingsList
          .where((goal) => goal.isSynced == false)
          .toList();
      if (pendingGoals.isEmpty) return;

      for (var goal in pendingGoals) {
        await savingGoalRepo
            .addSavingGoal(goal)
            .then((_) => add(BucketsEventMarkSynced(goalId: goal.id)))
            .catchError((e) => log('Failed to sync goal ${goal.id}: $e'));
      }
      _syncToSharedPreferences(state.savingsList);
    });

    on<BucketsEventBulkCreate>((event, emit) async {
      try {
        if (event.goals.isEmpty) {
          event.completer?.complete();
          return;
        }

        final userId = authRepository.currentUser?.uid ?? '';
        final normalizedGoals = <SavingGoalModel>[];
        final seenKeys = <String>{};

        for (final goal in event.goals) {
          final normalized = goal.copyWith(
            id: goal.id.isEmpty ? const Uuid().v4() : goal.id,
            userId: userId,
            isSynced: false,
          );

          if (seenKeys.add(_savingGoalImportKey(normalized))) {
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
        emit(BucketsStateSuccess(savingsList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          final syncedGoals = normalizedGoals
              .map((goal) => goal.copyWith(isSynced: true))
              .toList();
          final persistedGoals = await savingGoalRepo
              .bulkCreateGoalsWithAccounts(syncedGoals);

          final persistedById = {
            for (final goal in persistedGoals)
              goal.id: goal.copyWith(isSynced: true),
          };
          final finalList = updatedList.map((goal) {
            return persistedById[goal.id] ?? goal;
          }).toList();

          _syncToSharedPreferences(finalList);
          emit(BucketsStateSuccess(savingsList: finalList));
        }

        event.completer?.complete();
      } catch (e) {
        event.completer?.completeError(e);
        log('Failed to bulk import savings goals: ${e.toString()}');
        emit(
          BucketsStateError(
            message: 'Failed to bulk import savings goals: ${e.toString()}',
            savingsList: state.savingsList,
          ),
        );
      }
    });
  }

  void _syncToSharedPreferences(List<SavingGoalModel> goals) {
    final List<Map<String, dynamic>> mapList = goals
        .map((s) => s.toMap())
        .toList();
    settingsBloc.add(SettingsEventSyncSavingsSnapshot(mapList));
  }

  String _savingGoalImportKey(SavingGoalModel goal) {
    return [
      goal.name.toLowerCase(),
      goal.currency.toLowerCase(),
      goal.sourceAccountId.toLowerCase(),
    ].join('|');
  }

  void _scheduleNotifications(SavingGoalModel goal) async {
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

  void _cancelNotifications(SavingGoalModel goal) async {
    final baseId = goal.id.hashCode.abs();
    for (int i = 0; i < 7; i++) {
      await NotificationRepository.cancelNotificationById(baseId + i);
    }
    await NotificationRepository.cancelNotificationById(baseId + 100);
  }

  @override
  BucketsState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic>? list = json['savingsList'];
      if (list == null) {
        return const BucketsStateSuccess(savingsList: []);
      }
      final List<SavingGoalModel> savingsList = list
          .map((e) => SavingGoalModel.fromMap(e))
          .toList();

      // Mirror to Snapshot on load
      _syncToSharedPreferences(savingsList);

      return BucketsStateSuccess(savingsList: savingsList);
    } catch (e) {
      log('Error During Savings Serialization: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(BucketsState state) {
    return {
      'savingsList': state.savingsList.map((goal) => goal.toMap()).toList(),
    };
  }
}
