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

class SettingsEventOnBoardingChange extends SettingsEvent {
  const SettingsEventOnBoardingChange();
}

class SettingsEventLoggedIn extends SettingsEvent {
  const SettingsEventLoggedIn();
}
