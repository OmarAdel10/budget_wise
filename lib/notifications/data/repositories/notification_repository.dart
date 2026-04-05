import 'dart:developer';
import 'package:budget_wise/main.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/transaction/view/screens/pending_sms_transactions_screen.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationRepository {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  // Notification ID Ranges
  static const int SAVINGS_RANGE_START = 1000;
  static const int SAVINGS_RANGE_END = 1999;
  static const int SUBS_RANGE_START = 2000;
  static const int SUBS_RANGE_END = 2999;
  static const int SMS_RANGE_START = 3000;
  static const int SMS_RANGE_END = 3999;

  @pragma('vm:entry-point')
  static void onReciveTap(NotificationResponse notificationResponse) {
    log('ID: ${notificationResponse.id}');
    log('PAYLOAD: ${notificationResponse.payload}');

    final payload = notificationResponse.payload;
    if (payload == null) return;

    if (payload == 'sms_draft_confirm') {
      BudgetWise.navigatorKey.currentState?.pushNamed(
        PendingSmsTransactionsScreen.routeName,
      );
    } else if (payload == 'nav_savings') {
      BudgetWise.navigatorKey.currentState?.pushNamed('/savings');
    } else if (payload.startsWith('subscription_')) {
      final subId = payload.replaceFirst('subscription_', '');
      BudgetWise.navigatorKey.currentState?.pushNamed(
        SubscriptionDetailsScreen.routeName,
        arguments: subId,
      );
    } else if (payload.startsWith('add_transaction_with_context|')) {
      final parts = payload.split('|');
      if (parts.length >= 3) {
        final accountId = parts[1];
        final amount = parts[2];
        BudgetWise.navigatorKey.currentState?.pushNamed(
          '/add-transaction',
          arguments: {
            'initialAccountId': accountId,
            'initialAmount': double.tryParse(amount),
          },
        );
      }
    }
  }

  static bool _isInitialized = false;

  static Future<void> notificationInit() async {
    if (_isInitialized) return;

    try {
      await requestPermissions();

      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings iosInit =
          DarwinInitializationSettings();

      final InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await notifications.initialize(
        settings: initSettings,
        onDidReceiveBackgroundNotificationResponse: onReciveTap,
        onDidReceiveNotificationResponse: onReciveTap,
      );
      _isInitialized = true;
    } catch (e) {
      log('Notification initialization failed: $e');
    }
  }

  static Future<bool> isPermissionGranted() async {
    final androidGranted = await notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
    return androidGranted;
  }

  static Future<void> requestPermissions() async {
    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static void showNotificationStack() async {
    if (!_isInitialized) await notificationInit();
    final getActiveNotifications = await notifications.getActiveNotifications();
    log('getActiveNotifications: $getActiveNotifications');
    final getNotificationAppLaunchDetails = await notifications
        .getNotificationAppLaunchDetails();
    log('getNotificationAppLaunchDetails: $getNotificationAppLaunchDetails');
    final pendingNotificationRequests = await notifications
        .pendingNotificationRequests();
    log('pendingNotificationRequests: $pendingNotificationRequests');
  }

  static Future<void> instantNotification({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) await notificationInit();

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            channelShowBadge: true,
            importance: Importance.max,
            priority: Priority.max,
            ticker: 'ticker',
          );

      await notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: androidDetails),
        payload: payload ?? 'Instant Notification For $title',
      );
    } catch (e) {
      log('Catch Instant Notification error $e');
    }
  }

  static Future<void> scheduledNotification({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) await notificationInit();

      final NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          channelShowBadge: true,
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'ticker',
        ),
      );
      tz.initializeTimeZones();
      final TimezoneInfo currentTimeZone =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledDate.hour,
        scheduledDate.minute,
        scheduledDate.second,
      );
      await notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload ?? 'Schedule Notification For $title',
      );
    } catch (e) {
      log('Scheduled Notification error $e');
    }
  }

  static Future<void> cancelNotificationById(int id) async {
    try {
      await notifications.cancel(id: id);
    } catch (e) {
      log('Error canceling notification $id: $e');
    }
  }

  static Future<void> cancelNotificationsInRange(int start, int end) async {
    try {
      final pendingRequests = await notifications.pendingNotificationRequests();
      for (final request in pendingRequests) {
        if (request.id >= start && request.id <= end) {
          await notifications.cancel(id: request.id);
        }
      }
    } catch (e) {
      log('Error canceling notifications in range $start-$end: $e');
    }
  }
}
