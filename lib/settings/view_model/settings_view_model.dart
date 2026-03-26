import 'dart:developer';

import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc()
    : super(
        SettingsInitial(
          SettingsModel(),
          _getCurrencyName(SettingsModel().defaultCurrency),
        ),
      ) {
    // Initial sync of notification settings to SharedPreferences
    _syncNotificationSettingsToPrefs(state.model);

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
          _getCurrencyName(newModel.defaultCurrency),
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

    on<SettingsEventToggleAllNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        allNotificationsEnabled: !state.model.allNotificationsEnabled,
      );
      if (!newModel.allNotificationsEnabled) {
        NotificationRepository.notifications.cancelAll();
      }
      _syncNotificationSettingsToPrefs(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleSmsNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        smsNotificationsEnabled: !state.model.smsNotificationsEnabled,
      );
      _syncNotificationSettingsToPrefs(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleSubscriptionNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        subscriptionNotificationsEnabled:
            !state.model.subscriptionNotificationsEnabled,
      );
      if (!newModel.subscriptionNotificationsEnabled) {
        // Just cancel all for now if disabled, they can be rescheduled when turned back on
        NotificationRepository.notifications.cancelAll();
      }
      _syncNotificationSettingsToPrefs(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleSavingsNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        savingsNotificationsEnabled: !state.model.savingsNotificationsEnabled,
      );
      _syncNotificationSettingsToPrefs(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });
  }

  void _syncNotificationSettingsToPrefs(SettingsModel model) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        'all_notifications_enabled',
        model.allNotificationsEnabled,
      );
      await prefs.setBool(
        'sms_notifications_enabled',
        model.smsNotificationsEnabled,
      );
      await prefs.setBool(
        'subscription_notifications_enabled',
        model.subscriptionNotificationsEnabled,
      );
      await prefs.setBool(
        'savings_notifications_enabled',
        model.savingsNotificationsEnabled,
      );
    } catch (e) {
      log('Failed to sync notification settings to SharedPreferences: $e');
    }
  }

  static String _getCurrencyName(String currencyCode) {
    return NumberFormat.simpleCurrency(name: currencyCode).currencyName!;
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      final model = SettingsModel.fromMap(
        json['settingsModel'] as Map<String, dynamic>,
      );
      // Ensure SharedPreferences is updated after loading from Hydrated storage
      _syncNotificationSettingsToPrefs(model);
      return SettingsStateSuccess(
        model,
        _getCurrencyName(model.defaultCurrency),
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
