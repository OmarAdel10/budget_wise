import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:equatable/equatable.dart';

sealed class SettingsState extends Equatable {
  final SettingsModel model;
  final String currencySymbol;
  const SettingsState(this.model, this.currencySymbol);

  @override
  List<Object?> get props => [model, currencySymbol];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial(super.model, super.currencySymbol);

  @override
  List<Object?> get props => [model, currencySymbol];
}

class SettingsStateSuccess extends SettingsState {
  const SettingsStateSuccess(super.model, super.currencySymbol);

  @override
  List<Object?> get props => [model, currencySymbol];
}

class SettingsStateError extends SettingsState {
  final String message;
  const SettingsStateError(this.message, super.model, super.currencySymbol);

  @override
  List<Object?> get props => [message, model, currencySymbol];
}
