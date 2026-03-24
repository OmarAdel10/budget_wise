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

  @pragma('vm:entry-point')
  static void onReciveTap(NotificationResponse notificationResponse) {
    log('ID: ${notificationResponse.id}');
    log('PAYLOAD: ${notificationResponse.payload}');

    if (notificationResponse.payload == 'sms_draft_confirm') {
      BudgetWise.navigatorKey.currentState?.pushNamed(
        PendingSmsTransactionsScreen.routeName,
      );
    } else if (notificationResponse.payload?.startsWith('subscription_') ??
        false) {
      final subId = notificationResponse.payload!.replaceFirst(
        'subscription_',
        '',
      );
      BudgetWise.navigatorKey.currentState?.pushNamed(
        SubscriptionDetailsScreen.routeName,
        arguments: subId,
      );
    }
  }

  static bool _isInitialized = false;

  static Future<void> notificationInit() async {
    if (_isInitialized) return;

    try {
      await notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

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
}
