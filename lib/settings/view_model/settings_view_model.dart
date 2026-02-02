import 'dart:developer';

import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial(SettingsModel())) {
    on<SettingsEventLocalAuth>((event, emit) {
      emit(
        SettingsStateSuccess(
          state.model.copyWith(localAuthEnabled: !state.model.localAuthEnabled),
        ),
      );
    });

    on<SettingsEventLanguageChange>((event, emit) {
      emit(
        SettingsStateSuccess(state.model.copyWith(language: event.language)),
      );
    });

    on<SettingsEventOnBoardingFinished>((event, emit) {
      emit(
        SettingsStateSuccess(state.model.copyWith(isOnboardingCompleted: true)),
      );
    });

    on<SettingsEventLoggedIn>((event, emit) {
      emit(SettingsStateSuccess(state.model.copyWith(hasLoggedIn: true)));
    });

    on<SettingsEventLoggedOut>((event, emit) {
      emit(SettingsStateSuccess(state.model.copyWith(hasLoggedIn: false)));
    });
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      final model = SettingsModel.fromMap(
        json['settingsModel'] as Map<String, dynamic>,
      );
      return SettingsStateSuccess(model);
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
