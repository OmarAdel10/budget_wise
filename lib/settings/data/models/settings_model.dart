// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  final bool localAuthEnabled;
  final String language;
  final bool isOnboardingCompleted;
  final bool isDataSyncSuccess;
  final bool hasLoggedIn;

  const SettingsModel({
    this.localAuthEnabled = false,
    this.language = 'en',
    this.isOnboardingCompleted = false,
    this.isDataSyncSuccess = false,
    this.hasLoggedIn = false,
  });

  SettingsModel copyWith({
    bool? localAuthEnabled,
    String? language,
    bool? isOnboardingCompleted,
    bool? isDataSyncSuccess,
    bool? hasLoggedIn,
  }) {
    return SettingsModel(
      localAuthEnabled: localAuthEnabled ?? this.localAuthEnabled,
      language: language ?? this.language,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      isDataSyncSuccess: isDataSyncSuccess ?? this.isDataSyncSuccess,
      hasLoggedIn: hasLoggedIn ?? this.hasLoggedIn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'localAuthEnabled': localAuthEnabled,
      'language': language,
      'isOnboardingCompleted': isOnboardingCompleted,
      'isDataSyncSuccess': isDataSyncSuccess,
      'hasLoggedIn': hasLoggedIn,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      localAuthEnabled: map['localAuthEnabled'] as bool,
      language: map['language'] as String,
      isOnboardingCompleted: map['isOnboardingCompleted'] as bool,
      isDataSyncSuccess: map['isDataSyncSuccess'] as bool,
      hasLoggedIn: map['hasLoggedIn'] as bool,
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
    isDataSyncSuccess,
    hasLoggedIn,
  ];
}
