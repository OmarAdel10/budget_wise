import 'package:budget_wise/buckets/data/models/saving_goal_model.dart';
import 'package:equatable/equatable.dart';

abstract class BucketsState extends Equatable {
  final List<SavingGoalModel> savingsList;
  const BucketsState({required this.savingsList});

  @override
  List<Object?> get props => [savingsList];
}

class BucketsStateInitial extends BucketsState {
  const BucketsStateInitial({required super.savingsList});
}

class BucketsStateSuccess extends BucketsState {
  final bool showCompletionToast;
  final String? completedGoalName;

  const BucketsStateSuccess({
    required super.savingsList,
    this.showCompletionToast = false,
    this.completedGoalName,
  });

  @override
  List<Object?> get props => [savingsList, showCompletionToast, completedGoalName];
}

class BucketsStateLoading extends BucketsState {
  const BucketsStateLoading({required super.savingsList});
}

class BucketsStateError extends BucketsState {
  final String message;
  const BucketsStateError({required this.message, required super.savingsList});

  @override
  List<Object?> get props => [message, savingsList];
}
