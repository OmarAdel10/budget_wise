import 'package:budget_wise/settings/data/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer';

class SettingsRepository {
  static const String _allNotificationsKey = 'all_notifications_enabled';
  static const String _smsNotificationsKey = 'sms_notifications_enabled';
  static const String _subscriptionNotificationsKey =
      'subscription_notifications_enabled';
  static const String _savingsNotificationsKey =
      'savings_notifications_enabled';
  static const String _accountsSnapshotKey = 'bg_accounts_snapshot';
  static const String _savingsSnapshotKey = 'bg_savings_snapshot';

  Future<void> saveNotificationSettings(SettingsModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_allNotificationsKey, model.allNotificationsEnabled);
      await prefs.setBool(_smsNotificationsKey, model.smsNotificationsEnabled);
      await prefs.setBool(
        _subscriptionNotificationsKey,
        model.subscriptionNotificationsEnabled,
      );
      await prefs.setBool(
        _savingsNotificationsKey,
        model.savingsNotificationsEnabled,
      );
    } catch (e) {
      log('SettingsRepository: Failed to save notification settings: $e');
    }
  }

  Future<bool> getNotificationStatus(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? true;
    } catch (e) {
      log('SettingsRepository: Failed to get notification status for $key: $e');
      return true;
    }
  }

  Future<void> syncAccountsSnapshot(List<Map<String, dynamic>> accounts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accountsSnapshotKey, jsonEncode(accounts));
    } catch (e) {
      log('SettingsRepository: Failed to sync accounts snapshot: $e');
    }
  }

  Future<void> syncSavingsSnapshot(List<Map<String, dynamic>> savings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savingsSnapshotKey, jsonEncode(savings));
    } catch (e) {
      log('SettingsRepository: Failed to sync savings snapshot: $e');
    }
  }
}
