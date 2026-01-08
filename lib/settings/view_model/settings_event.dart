sealed class SettingsEvent{
  const SettingsEvent();
}

class SettingsEventLocalAuth extends SettingsEvent{
  const SettingsEventLocalAuth();
}

class SettingsEventLanguageChange extends SettingsEvent{
  final String language;
  const SettingsEventLanguageChange(this.language);
}

class SettingsEventOnBoardingChange extends SettingsEvent{
  final bool isOnboardingCompleted;
  const SettingsEventOnBoardingChange(this.isOnboardingCompleted);
}

class SettingsEventSyncDataAfterFirstLogin extends SettingsEvent{
  final bool isDataSyncedAfterFirstLogin;
  const SettingsEventSyncDataAfterFirstLogin(this.isDataSyncedAfterFirstLogin);
}

class SettingsEventSyncToCloud extends SettingsEvent{
  const SettingsEventSyncToCloud();
}