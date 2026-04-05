import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:equatable/equatable.dart';

abstract class SavingsState extends Equatable {
  final List<SavingsModel> savingsList;
  const SavingsState({required this.savingsList});

  @override
  List<Object?> get props => [savingsList];
}

class SavingsStateInitial extends SavingsState {
  const SavingsStateInitial({required super.savingsList});
}

class SavingsStateSuccess extends SavingsState {
  final bool showCompletionToast;
  final String? completedGoalName;

  const SavingsStateSuccess({
    required super.savingsList,
    this.showCompletionToast = false,
    this.completedGoalName,
  });

  @override
  List<Object?> get props => [savingsList, showCompletionToast, completedGoalName];
}

class SavingsStateLoading extends SavingsState {
  const SavingsStateLoading({required super.savingsList});
}

class SavingsStateError extends SavingsState {
  final String message;
  const SavingsStateError({required this.message, required super.savingsList});

  @override
  List<Object?> get props => [message, savingsList];
}
