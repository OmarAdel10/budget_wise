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
