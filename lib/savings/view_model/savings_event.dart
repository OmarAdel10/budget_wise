import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:equatable/equatable.dart';

abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object?> get props => [];
}

class SavingsEventFetchAll extends SavingsEvent {
  const SavingsEventFetchAll();
}

class SavingsEventCreateGoal extends SavingsEvent {
  final SavingsModel model;
  const SavingsEventCreateGoal({required this.model});

  @override
  List<Object?> get props => [model];
}

class SavingsEventEditGoal extends SavingsEvent {
  final SavingsModel model;
  const SavingsEventEditGoal({required this.model});

  @override
  List<Object?> get props => [model];
}

class SavingsEventDeleteGoal extends SavingsEvent {
  final String goalId;
  const SavingsEventDeleteGoal({required this.goalId});

  @override
  List<Object?> get props => [goalId];
}

class SavingsEventToggleDayContribution extends SavingsEvent {
  final String goalId;
  final int day;
  const SavingsEventToggleDayContribution({
    required this.goalId,
    required this.day,
  });

  @override
  List<Object?> get props => [goalId, day];
}

class SavingsEventUpdateCustomAmount extends SavingsEvent {
  final String goalId;
  final int day;
  final double amount;
  const SavingsEventUpdateCustomAmount({
    required this.goalId,
    required this.day,
    required this.amount,
  });

  @override
  List<Object?> get props => [goalId, day, amount];
}

class SavingsEventMarkSynced extends SavingsEvent {
  final String goalId;
  const SavingsEventMarkSynced({required this.goalId});

  @override
  List<Object?> get props => [goalId];
}

class SavingsEventSyncPendingOnLogin extends SavingsEvent {
  const SavingsEventSyncPendingOnLogin();
}

class SavingsEventCheckAndSyncPending extends SavingsEvent {
  const SavingsEventCheckAndSyncPending();
}
