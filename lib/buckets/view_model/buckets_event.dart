import 'dart:async';

import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:equatable/equatable.dart';

abstract class BucketsEvent extends Equatable {
  const BucketsEvent();

  @override
  List<Object?> get props => [];
}

class BucketsEventFetchAll extends BucketsEvent {
  const BucketsEventFetchAll();
}

class BucketsEventCreateGoal extends BucketsEvent {
  final SavingGoalModel model;
  const BucketsEventCreateGoal({required this.model});

  @override
  List<Object?> get props => [model];
}

class BucketsEventEditGoal extends BucketsEvent {
  final SavingGoalModel model;
  const BucketsEventEditGoal({required this.model});

  @override
  List<Object?> get props => [model];
}

class BucketsEventDeleteGoal extends BucketsEvent {
  final String goalId;
  const BucketsEventDeleteGoal({required this.goalId});

  @override
  List<Object?> get props => [goalId];
}

class BucketsEventToggleDayContribution extends BucketsEvent {
  final String goalId;
  final int day;
  const BucketsEventToggleDayContribution({
    required this.goalId,
    required this.day,
  });

  @override
  List<Object?> get props => [goalId, day];
}

class BucketsEventUpdateCustomAmount extends BucketsEvent {
  final String goalId;
  final int day;
  final double amount;
  const BucketsEventUpdateCustomAmount({
    required this.goalId,
    required this.day,
    required this.amount,
  });

  @override
  List<Object?> get props => [goalId, day, amount];
}

class BucketsEventMarkSynced extends BucketsEvent {
  final String goalId;
  const BucketsEventMarkSynced({required this.goalId});

  @override
  List<Object?> get props => [goalId];
}

class BucketsEventSyncPendingOnLogin extends BucketsEvent {
  const BucketsEventSyncPendingOnLogin();
}

class BucketsEventCheckAndSyncPending extends BucketsEvent {
  const BucketsEventCheckAndSyncPending();
}

class BucketsEventBulkCreate extends BucketsEvent {
  final List<SavingGoalModel> goals;
  final Completer<void>? completer;

  const BucketsEventBulkCreate({required this.goals, this.completer});

  @override
  List<Object?> get props => [goals];
}
