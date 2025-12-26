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