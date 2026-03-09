import 'dart:developer';

import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc()
    : super(
        SettingsInitial(
          SettingsModel(),
          _getCurrencySymbol(SettingsModel().defaultCurrency),
        ),
      ) {
    on<SettingsEventLocalAuth>((event, emit) {
      final newModel = state.model.copyWith(
        localAuthEnabled: !state.model.localAuthEnabled,
      );
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventLanguageChange>((event, emit) {
      final newModel = state.model.copyWith(language: event.language);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventOnBoardingFinished>((event, emit) {
      final newModel = state.model.copyWith(isOnboardingCompleted: true);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventLoggedIn>((event, emit) {
      final newModel = state.model.copyWith(hasLoggedIn: true);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventLoggedOut>((event, emit) {
      final newModel = state.model.copyWith(hasLoggedIn: false);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventUpdateLastForegroundActivityDateTime>((event, emit) {
      final newModel = state.model.copyWith(
        lastForegroundActivityDateTime: event.dateTime,
      );
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventUpdateDefaultCurrency>((event, emit) {
      final newModel = state.model.copyWith(
        defaultCurrency: event.newDefaultCurrency,
      );
      emit(
        SettingsStateSuccess(
          newModel,
          _getCurrencySymbol(newModel.defaultCurrency),
        ),
      );
    });

    on<SettingsEventUpdatePasscode>((event, emit) {
      final newModel = state.model.copyWith(passcode: event.passcode);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleBiometrics>((event, emit) {
      final newModel = state.model.copyWith(
        useBiometrics: !state.model.useBiometrics,
      );
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });
  }

  static String _getCurrencySymbol(String currencyCode) {
    return NumberFormat.currency(name: currencyCode).currencySymbol;
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      final model = SettingsModel.fromMap(
        json['settingsModel'] as Map<String, dynamic>,
      );
      return SettingsStateSuccess(
        model,
        _getCurrencySymbol(model.defaultCurrency),
      );
    } catch (e) {
      log('Error During Serialization: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    try {
      return {'settingsModel': state.model.toMap()};
    } catch (e) {
      log('Error During Deserialization: $e');
      return null;
    }
  }
}
