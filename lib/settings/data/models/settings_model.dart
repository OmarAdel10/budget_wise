// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  final bool localAuthEnabled;
  final String language;
  final bool isOnboardingCompleted;
  final bool hasLoggedIn;
  final DateTime? lastForegroundActivityDateTime;
  final String defaultCurrency;
  final String? passcode;
  final bool useBiometrics;
  final bool allNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final bool subscriptionNotificationsEnabled;
  final bool savingsNotificationsEnabled;
  final bool categoryBudgetNotificationsEnabled;
  final bool dailyReminderNotificationsEnabled;

  const SettingsModel({
    this.localAuthEnabled = false,
    this.language = 'en',
    this.isOnboardingCompleted = false,
    this.hasLoggedIn = false,
    this.lastForegroundActivityDateTime,
    this.defaultCurrency = 'EGP',
    this.passcode,
    this.useBiometrics = true,
    this.allNotificationsEnabled = true,
    this.smsNotificationsEnabled = true,
    this.subscriptionNotificationsEnabled = true,
    this.savingsNotificationsEnabled = true,
    this.categoryBudgetNotificationsEnabled = true,
    this.dailyReminderNotificationsEnabled = true,
  });

  bool get isPasscodeSet => passcode != null && passcode!.length == 4;

  SettingsModel copyWith({
    bool? localAuthEnabled,
    String? language,
    bool? isOnboardingCompleted,
    bool? isDataSyncSuccess,
    bool? hasLoggedIn,
    DateTime? lastForegroundActivityDateTime,
    String? defaultCurrency,
    String? passcode,
    bool? useBiometrics,
    bool? allNotificationsEnabled,
    bool? smsNotificationsEnabled,
    bool? subscriptionNotificationsEnabled,
    bool? savingsNotificationsEnabled,
    bool? categoryBudgetNotificationsEnabled,
    bool? dailyReminderNotificationsEnabled,
  }) {
    return SettingsModel(
      localAuthEnabled: localAuthEnabled ?? this.localAuthEnabled,
      language: language ?? this.language,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      hasLoggedIn: hasLoggedIn ?? this.hasLoggedIn,
      lastForegroundActivityDateTime:
          lastForegroundActivityDateTime ?? this.lastForegroundActivityDateTime,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      passcode: passcode ?? this.passcode,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      allNotificationsEnabled:
          allNotificationsEnabled ?? this.allNotificationsEnabled,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      subscriptionNotificationsEnabled:
          subscriptionNotificationsEnabled ??
          this.subscriptionNotificationsEnabled,
      savingsNotificationsEnabled:
          savingsNotificationsEnabled ?? this.savingsNotificationsEnabled,
      categoryBudgetNotificationsEnabled:
          categoryBudgetNotificationsEnabled ??
          this.categoryBudgetNotificationsEnabled,
      dailyReminderNotificationsEnabled:
          dailyReminderNotificationsEnabled ??
          this.dailyReminderNotificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'localAuthEnabled': localAuthEnabled,
      'language': language,
      'isOnboardingCompleted': isOnboardingCompleted,
      'hasLoggedIn': hasLoggedIn,
      'lastForegroundActivityDateTime':
          lastForegroundActivityDateTime?.toIso8601String(),
      'defaultCurrency': defaultCurrency,
      'passcode': passcode,
      'useBiometrics': useBiometrics,
      'allNotificationsEnabled': allNotificationsEnabled,
      'smsNotificationsEnabled': smsNotificationsEnabled,
      'subscriptionNotificationsEnabled': subscriptionNotificationsEnabled,
      'savingsNotificationsEnabled': savingsNotificationsEnabled,
      'categoryBudgetNotificationsEnabled': categoryBudgetNotificationsEnabled,
      'dailyReminderNotificationsEnabled': dailyReminderNotificationsEnabled,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      localAuthEnabled: map['localAuthEnabled'] as bool,
      language: map['language'] as String,
      isOnboardingCompleted: map['isOnboardingCompleted'] as bool,
      hasLoggedIn: map['hasLoggedIn'] as bool,
      lastForegroundActivityDateTime:
          map['lastForegroundActivityDateTime'] != null
              ? DateTime.parse(map['lastForegroundActivityDateTime'] as String)
              : null,
      defaultCurrency: map['defaultCurrency'] as String,
      passcode: map['passcode'] as String?,
      useBiometrics: map['useBiometrics'] as bool? ?? true,
      allNotificationsEnabled: map['allNotificationsEnabled'] as bool? ?? true,
      smsNotificationsEnabled: map['smsNotificationsEnabled'] as bool? ?? true,
      subscriptionNotificationsEnabled:
          map['subscriptionNotificationsEnabled'] as bool? ?? true,
      savingsNotificationsEnabled:
          map['savingsNotificationsEnabled'] as bool? ?? true,
      categoryBudgetNotificationsEnabled:
          map['categoryBudgetNotificationsEnabled'] as bool? ?? true,
      dailyReminderNotificationsEnabled:
          map['dailyReminderNotificationsEnabled'] as bool? ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsModel.fromJson(String source) =>
      SettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        localAuthEnabled,
        language,
        isOnboardingCompleted,
        hasLoggedIn,
        lastForegroundActivityDateTime,
        defaultCurrency,
        passcode,
        useBiometrics,
        allNotificationsEnabled,
        smsNotificationsEnabled,
        subscriptionNotificationsEnabled,
        savingsNotificationsEnabled,
        categoryBudgetNotificationsEnabled,
        dailyReminderNotificationsEnabled,
      ];
}
