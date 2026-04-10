import 'dart:developer';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:budget_wise/settings/data/repositories/settings_repository.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository})
    : super(
        SettingsInitial(
          SettingsModel(),
          _getCurrencyName(SettingsModel().defaultCurrency),
        ),
      ) {
    // Initial sync of notification settings to Repository/Snapshots
    settingsRepository.saveNotificationSettings(state.model);

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

    on<SettingsEventBankMarginChanged>((event, emit) {
      final newModel = state.model.copyWith(bankMargin: event.bankMargin);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleAllNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        allNotificationsEnabled: !state.model.allNotificationsEnabled,
      );
      if (!newModel.allNotificationsEnabled) {
        NotificationRepository.notifications.cancelAll();
      }
      settingsRepository.saveNotificationSettings(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleSmsNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        smsNotificationsEnabled: !state.model.smsNotificationsEnabled,
      );
      if (!newModel.smsNotificationsEnabled) {
        NotificationRepository.cancelNotificationsInRange(
          NotificationRepository.smsRangeStart,
          NotificationRepository.smsRangeEnd,
        );
      }
      settingsRepository.saveNotificationSettings(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleSubscriptionNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        subscriptionNotificationsEnabled:
            !state.model.subscriptionNotificationsEnabled,
      );
      if (!newModel.subscriptionNotificationsEnabled) {
        NotificationRepository.cancelNotificationsInRange(
          NotificationRepository.subsRangeStart,
          NotificationRepository.subsRangeEnd,
        );
      }
      settingsRepository.saveNotificationSettings(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleSavingsNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        savingsNotificationsEnabled: !state.model.savingsNotificationsEnabled,
      );
      if (!newModel.savingsNotificationsEnabled) {
        NotificationRepository.cancelNotificationsInRange(
          NotificationRepository.savingsRangeStart,
          NotificationRepository.savingsRangeEnd,
        );
      }
      settingsRepository.saveNotificationSettings(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleCategoryBudgetNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        categoryBudgetNotificationsEnabled:
            !state.model.categoryBudgetNotificationsEnabled,
      );
      if (!newModel.categoryBudgetNotificationsEnabled) {
        NotificationRepository.cancelNotificationsInRange(
          NotificationRepository.categoriesRangeStart,
          NotificationRepository.categoriesRangeEnd,
        );
      }
      settingsRepository.saveNotificationSettings(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventToggleDailyReminderNotifications>((event, emit) {
      final newModel = state.model.copyWith(
        dailyReminderNotificationsEnabled:
            !state.model.dailyReminderNotificationsEnabled,
      );
      if (!newModel.dailyReminderNotificationsEnabled) {
        NotificationRepository.cancelNotificationsInRange(
          NotificationRepository.dailyReminderRangeStart,
          NotificationRepository.dailyReminderRangeEnd,
        );
      }
      settingsRepository.saveNotificationSettings(newModel);
      emit(SettingsStateSuccess(newModel, state.currencySymbol));
    });

    on<SettingsEventSyncAccountsSnapshot>((event, emit) async {
      await settingsRepository.syncAccountsSnapshot(event.accounts);
    });

    on<SettingsEventSyncSavingsSnapshot>((event, emit) async {
      await settingsRepository.syncSavingsSnapshot(event.savings);
    });
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
      // Ensure snapshots are updated after loading from Hydrated storage
      settingsRepository.saveNotificationSettings(model);
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
