import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:equatable/equatable.dart';

sealed class SettingsState extends Equatable {
  final SettingsModel model;
  const SettingsState(this.model);

  @override
  List<Object?> get props => [model];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial(super.model);

  @override
  List<Object?> get props => [model];
}

class SettingsStateSuccess extends SettingsState {
  const SettingsStateSuccess(super.model);

  @override
  List<Object?> get props => [model];
}

class SettingsStateError extends SettingsState {
  final String message;
  const SettingsStateError(this.message, super.model);

  @override
  List<Object?> get props => [message, model];
}
