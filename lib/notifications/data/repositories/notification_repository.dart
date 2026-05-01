import 'dart:async';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationRepository {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static final StreamController<String?> _payloadController =
      StreamController<String?>.broadcast();
  static Stream<String?> get payloadStream => _payloadController.stream;

  // Notification ID Ranges
  static const int savingsRangeStart = 1000;
  static const int savingsRangeEnd = 1999;
  static const int subsRangeStart = 2000;
  static const int subsRangeEnd = 2999;
  static const int smsRangeStart = 3000;
  static const int smsRangeEnd = 3999;
  static const int accountsRangeStart = 4000;
  static const int accountsRangeEnd = 4999;
  static const int categoriesRangeStart = 5000;
  static const int categoriesRangeEnd = 5999;
  static const int transactionsRangeStart = 6000;
  static const int transactionsRangeEnd = 6999;
  static const int dailyReminderRangeStart = 7000;
  static const int dailyReminderRangeEnd = 7999;

  @pragma('vm:entry-point')
  static void onReciveTap(NotificationResponse notificationResponse) {
    log('Notification Tapped - ID: ${notificationResponse.id}, Payload: ${notificationResponse.payload}');
    _payloadController.add(notificationResponse.payload);
  }

  static bool _isInitialized = false;

  static Future<void> notificationInit() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Timezones once at startup
      tz.initializeTimeZones();
      final TimezoneInfo currentTimeZone =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@drawable/app_icon_v2_transparent');
      final DarwinInitializationSettings darwinInit =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      await notifications.initialize(
        settings: initSettings,
        onDidReceiveBackgroundNotificationResponse: onReciveTap,
        onDidReceiveNotificationResponse: onReciveTap,
      );
      _isInitialized = true;
    } catch (e) {
      log('Notification initialization failed: $e');
      rethrow;
    }
  }

  static Future<bool> isPermissionGranted() async {
    final androidGranted = await notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    final iosGranted = await notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;

    return androidGranted || iosGranted;
  }

  static Future<void> requestPermissions() async {
    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await notifications
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
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

      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        ),
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

      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload ?? 'Schedule Notification For $title',
      );
    } catch (e) {
      log('Scheduled Notification error $e');
    }
  }

  static Future<void> scheduleDailyNotification({
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

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        channelShowBadge: true,
        importance: Importance.max,
        priority: Priority.max,
      );

      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload ?? 'Daily Schedule For $title',
      );
    } catch (e) {
      log('Daily Scheduled Notification error $e');
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
      // 1. Cancel future pending notifications
      final pendingRequests = await notifications.pendingNotificationRequests();
      for (final request in pendingRequests) {
        if (request.id >= start && request.id <= end) {
          await notifications.cancel(id: request.id);
        }
      }

      // 2. Clear already delivered/active notifications from system tray
      final activeNotifications = await notifications.getActiveNotifications();
      for (final active in activeNotifications) {
        if (active.id != null && active.id! >= start && active.id! <= end) {
          await notifications.cancel(id: active.id!);
        }
      }
    } catch (e) {
      log('Error canceling notifications in range $start-$end: $e');
    }
  }

  static void dispose() {
    _payloadController.close();
  }
}

