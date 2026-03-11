import 'dart:developer';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:budget_wise/savings/data/repositories/savings_repository.dart';
import 'package:budget_wise/savings/view_model/savings_event.dart';
import 'package:budget_wise/savings/view_model/savings_state.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

class SavingsBloc extends HydratedBloc<SavingsEvent, SavingsState> {
  final SettingsBloc settingsBloc;
  final SavingsRepository savingsRepo;
  final AuthRepository authRepository;

  SavingsBloc({
    required this.settingsBloc,
    required this.savingsRepo,
    required this.authRepository,
  }) : super(const SavingsStateInitial(savingsList: [])) {
    authRepository.authStateChanges.listen((user) {
      if (user != null && settingsBloc.state.model.hasLoggedIn) {
        add(const SavingsEventFetchAll());
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
          } else {
            if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
              updatedList.add(remoteItem);
            } else {
              updatedList.add(localItem);
            }
          }
          localGoalsMap.remove(remoteItem.id);
        }
        updatedList.addAll(localGoalsMap.values);

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

    on<SavingsEventCreateGoal>((event, emit) {
      final user = authRepository.currentUser;
      try {
        final newGoal = event.model.copyWith(
          id: event.model.id.isEmpty ? const Uuid().v4() : event.model.id,
          userId: user != null ? user.uid : '',
          isSynced: false,
        );

        final updatedList = [...state.savingsList, newGoal];
        emit(SavingsStateSuccess(savingsList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn) {
          savingsRepo
              .addSavingGoal(newGoal)
              .then((_) => add(SavingsEventMarkSynced(goalId: newGoal.id)))
              .catchError((e) {
                log('Cloud sync failed(create goal): ${e.toString()}');
                emit(
                  SavingsStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    savingsList: state.savingsList,
                  ),
                );
              });
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
        final updatedList = state.savingsList
            .where((goal) => goal.id != event.goalId)
            .toList();
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

    on<SavingsEventToggleDayContribution>((event, emit) {
      try {
        final updatedList = state.savingsList.map((goal) {
          if (goal.id == event.goalId) {
            final List<int> updatedDays = List.from(goal.completedDays);
            double newAmount = goal.currentAmount;

            if (updatedDays.contains(event.day)) {
              updatedDays.remove(event.day);
              newAmount -= event.day;
            } else {
              updatedDays.add(event.day);
              newAmount += event.day;
            }

            return goal.copyWith(
              completedDays: updatedDays,
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

        emit(SavingsStateSuccess(savingsList: updatedList));

        if (settingsBloc.state.model.hasLoggedIn) {
          savingsRepo
              .updateContribution(
                updatedGoal.id,
                updatedGoal.currentAmount,
                updatedGoal.completedDays,
                updatedGoal.updatedAt,
              )
              .then((_) => add(SavingsEventMarkSynced(goalId: updatedGoal.id)))
              .catchError((e) {
                log('Cloud sync failed(toggle contribution): ${e.toString()}');
                emit(
                  SavingsStateError(
                    message: 'Cloud sync failed: ${e.toString()}',
                    savingsList: state.savingsList,
                  ),
                );
              });
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

    on<SavingsEventMarkSynced>((event, emit) {
      final updatedList = state.savingsList
          .map(
            (goal) =>
                goal.id == event.goalId ? goal.copyWith(isSynced: true) : goal,
          )
          .toList();
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
    });
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
