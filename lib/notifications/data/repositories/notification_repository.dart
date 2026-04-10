import 'dart:developer';
import 'package:budget_wise/accounts/view/screens/account_detail_screen.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/category/view/screens/category_detail_screen.dart';
import 'package:budget_wise/main.dart';
import 'package:budget_wise/savings/view/screens/savings_screen.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/transaction/view/screens/add_transaction_screen.dart';
import 'package:budget_wise/transaction/view/screens/all_transactions_screen.dart';
import 'package:budget_wise/transaction/view/screens/pending_sms_transactions_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationRepository {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

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
    log('ID: ${notificationResponse.id}');
    log('PAYLOAD: ${notificationResponse.payload}');

    final payload = notificationResponse.payload;
    if (payload == null) return;

    if (payload == 'sms_draft_confirm') {
      BudgetWise.navigatorKey.currentState?.pushNamed(
        PendingSmsTransactionsScreen.routeName,
      );
    } else if (payload == 'nav_savings') {
      BudgetWise.navigatorKey.currentState?.pushNamed(SavingsScreen.routeName);
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
          AddTransactionScreen.routeName,
          arguments: {
            'initialAccountId': accountId,
            'initialAmount': double.tryParse(amount),
          },
        );
      }
    } else if (payload.startsWith('nav_account_')) {
      final accountId = payload.replaceFirst('nav_account_', '');
      final context = BudgetWise.navigatorKey.currentContext;
      if (context != null) {
        try {
          final accountBloc = context.read<AccountBloc>();
          final account = accountBloc.state.accountsList.firstWhere(
            (a) => a.id == accountId,
          );
          BudgetWise.navigatorKey.currentState?.pushNamed(
            AccountDetailScreen.routeName,
            arguments: account,
          );
        } catch (e) {
          log('Error navigating to account detail: $e');
        }
      }
    } else if (payload.startsWith('nav_category_')) {
      final categoryId = payload.replaceFirst('nav_category_', '');
      BudgetWise.navigatorKey.currentState?.pushNamed(
        CategoryDetailScreen.routeName,
        arguments: {'categoryId': categoryId},
      );
    } else if (payload == 'nav_transactions') {
      BudgetWise.navigatorKey.currentState?.pushNamed(
        AllTransactionsScreen.routeName,
      );
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
    final androidGranted =
        await notifications
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

      final NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          channelShowBadge: true,
          importance: Importance.max,
          priority: Priority.max,
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
