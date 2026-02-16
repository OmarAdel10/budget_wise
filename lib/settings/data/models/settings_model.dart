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

  const SettingsModel({
    this.localAuthEnabled = false,
    this.language = 'en',
    this.isOnboardingCompleted = false,
    this.hasLoggedIn = false,
    this.lastForegroundActivityDateTime,
    this.defaultCurrency = 'EGP',
  });

  SettingsModel copyWith({
    bool? localAuthEnabled,
    String? language,
    bool? isOnboardingCompleted,
    bool? isDataSyncSuccess,
    bool? hasLoggedIn,
    DateTime? lastForegroundActivityDateTime,
    String? defaultCurrency,
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
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'localAuthEnabled': localAuthEnabled,
      'language': language,
      'isOnboardingCompleted': isOnboardingCompleted,
      'hasLoggedIn': hasLoggedIn,
      'lastForegroundActivityDateTime': lastForegroundActivityDateTime
          ?.toIso8601String(),
      'defaultCurrency': defaultCurrency,
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
      defaultCurrency: map['defaultCurrency'] as String
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
  ];
}
