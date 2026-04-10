sealed class SettingsEvent {
  const SettingsEvent();
}

class SettingsEventLocalAuth extends SettingsEvent {
  const SettingsEventLocalAuth();
}

class SettingsEventLanguageChange extends SettingsEvent {
  final String language;
  const SettingsEventLanguageChange(this.language);
}

class SettingsEventOnBoardingFinished extends SettingsEvent {
  const SettingsEventOnBoardingFinished();
}

class SettingsEventLoggedIn extends SettingsEvent {
  const SettingsEventLoggedIn();
}

class SettingsEventLoggedOut extends SettingsEvent {
  const SettingsEventLoggedOut();
}

class SettingsEventUpdateLastForegroundActivityDateTime extends SettingsEvent {
  final DateTime? dateTime;
  const SettingsEventUpdateLastForegroundActivityDateTime(this.dateTime);
}

class SettingsEventUpdateDefaultCurrency extends SettingsEvent {
  final String newDefaultCurrency;

  const SettingsEventUpdateDefaultCurrency({required this.newDefaultCurrency});
}

class SettingsEventUpdatePasscode extends SettingsEvent {
  final String? passcode;
  const SettingsEventUpdatePasscode(this.passcode);
}

class SettingsEventToggleBiometrics extends SettingsEvent {
  const SettingsEventToggleBiometrics();
}

class SettingsEventBankMarginChanged extends SettingsEvent {
  final double bankMargin;
  const SettingsEventBankMarginChanged(this.bankMargin);
}

class SettingsEventToggleAllNotifications extends SettingsEvent {
  const SettingsEventToggleAllNotifications();
}

class SettingsEventToggleSmsNotifications extends SettingsEvent {
  const SettingsEventToggleSmsNotifications();
}

class SettingsEventToggleSubscriptionNotifications extends SettingsEvent {
  const SettingsEventToggleSubscriptionNotifications();
}

class SettingsEventToggleSavingsNotifications extends SettingsEvent {
  const SettingsEventToggleSavingsNotifications();
}

class SettingsEventSyncAccountsSnapshot extends SettingsEvent {
  final List<Map<String, dynamic>> accounts;
  const SettingsEventSyncAccountsSnapshot(this.accounts);
}

class SettingsEventSyncSavingsSnapshot extends SettingsEvent {
  final List<Map<String, dynamic>> savings;
  const SettingsEventSyncSavingsSnapshot(this.savings);
}
