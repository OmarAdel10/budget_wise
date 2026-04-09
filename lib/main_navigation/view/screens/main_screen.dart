import 'dart:async';
import 'package:another_telephony/telephony.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_details_screen.dart';
import 'package:budget_wise/transaction/data/models/sms_draft_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/accounts/view_model/account_event.dart';
import 'package:budget_wise/accounts/view_model/account_view_model.dart';
import 'package:budget_wise/category/view_model/category_event.dart';
import 'package:budget_wise/category/view_model/category_view_model.dart';
import 'package:budget_wise/transaction/view/screens/pending_sms_transactions_screen.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/settings/view_model/settings_event.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/subscriptions/view/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/shared/utils/sms_service.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/view/screens/home_screen.dart';
import '../../../accounts/view/screens/accounts_screen.dart';
import '../../../savings/view/screens/savings_screen.dart';
import '../../../statistics/view/screens/statistics_screen.dart';
import '../../../settings/view/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);
  DateTime _lastSyncTime = DateTime.now();
  final Duration _syncInterval = const Duration(minutes: 15);
  Timer? _periodicCheckTimer;
  final SmsService _smsService = SmsService();

  final List<Widget> _screens = [
    const HomeScreen(),
    const AccountsScreen(),
    const SubscriptionScreen(),
    const SavingsScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  void _onTabSelected(int newIndex) {
    _currentIndexNotifier.value = newIndex;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _performInitialSync();
    _startPeriodicCheck();
    _initSmsService();
    // Sequencing: Load drafts first, then check for notification launch
    _checkBackgroundSmsDrafts().then((_) {
      _handleLaunchNotification();
    });
    _scheduleDailyReminder();
  }

  Future<void> _handleLaunchNotification() async {
    final notificationAppLaunchDetails = await NotificationRepository
        .notifications
        .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails?.notificationResponse?.payload;
      if (payload == 'sms_draft_confirm') {
        if (mounted) {
          Navigator.pushNamed(context, PendingSmsTransactionsScreen.routeName);
        }
      } else if (payload!.startsWith('subscription_')) {
        final subId = payload.replaceFirst('subscription_', '');
        if (mounted) {
          Navigator.pushNamed(
            context,
            SubscriptionDetailsScreen.routeName,
            arguments: subId,
          );
        }
      }
    }
  }

  void _scheduleDailyReminder() {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      20, // 8 PM daily reminder
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    NotificationRepository.scheduleDailyNotification(
      channelId: 'daily_reminders',
      channelName: 'Daily Reminders',
      channelDescription: 'Daily reminder to log transactions',
      id: NotificationRepository.transactionsRangeStart,
      title: 'Time to Log Your Transactions',
      body:
          'Don\'t forget to log your daily expenses to keep your budget on track!',
      scheduledDate: scheduledDate,
      payload: 'nav_transactions',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicCheck();
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSyncIfNecessary();
      _startPeriodicCheck();

      // Targeted SMS scan for messages missed while app was inactive
      final oldLastTime = context
          .read<SettingsBloc>()
          .state
          .model
          .lastForegroundActivityDateTime;
      context.read<SettingsBloc>().add(
        const SettingsEventUpdateLastForegroundActivityDateTime(null),
      );

      if (oldLastTime != null) {
        _smsService.scanInboxSince(
          sinceDateTime: oldLastTime,
          accounts: context.read<AccountBloc>().state.accountsList,
          transactionBloc: context.read<TransactionBloc>(),
        );
      }

      _checkBackgroundSmsDrafts(); // Check for drafts saved by background isolate
      _initSmsService(); // Re-initialize SMS service on resume to ensure listener is active
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopPeriodicCheck();
      // Store current time when app leaves foreground
      context.read<SettingsBloc>().add(
        SettingsEventUpdateLastForegroundActivityDateTime(DateTime.now()),
      );
    }
  }

  Future<void> _checkBackgroundSmsDrafts() async {
    context.read<TransactionBloc>().add(
      const TransactionEventLoadBackgroundDrafts(),
    );

    // Safety Gate: Wait for the BLoC to finish processing if we are in a launch/resume context
    int attempts = 0;
    while (mounted &&
        context.read<TransactionBloc>().state.isProcessingBackgroundDrafts &&
        attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  Future<void> _initSmsService() async {
    final bool result = await _smsService.requestPermissions();
    if (result) {
      _smsService.listenForSms(
        onNewMessage: (SmsMessage message) async {
          //* This callback runs in the foreground isolate
          log("Foreground SMS received from: ${message.address}");
          final SmsDraftModel? smsDraft = _smsService.processMessage(
            message: message,
            accounts: context.read<AccountBloc>().state.accountsList,
          );

          if (smsDraft != null) {
            final String amountStr =
                "${smsDraft.extractedAmount?.toStringAsFixed(2)} ${smsDraft.extractedCurrency}";
            final String merchantStr =
                smsDraft.extractedMerchant ?? "Unknown Merchant";

            final SharedPreferences prefs = await SharedPreferences.getInstance();
            final bool allEnabled = prefs.getBool('all_notifications_enabled') ?? true;
            final bool smsEnabled = prefs.getBool('sms_notifications_enabled') ?? true;

            if (allEnabled && smsEnabled) {
              await NotificationRepository.instantNotification(
                id: smsDraft.timestamp.millisecondsSinceEpoch ~/ 1000,
                channelId: 'sms_transactions',
                channelName: 'SMS Transactions',
                channelDescription:
                    'Notifications for detected bank SMS transactions',
                title: 'New Transaction Detected',
                body: 'Detected $amountStr at $merchantStr. Tap to confirm.',
                payload:
                    'sms_draft_confirm', // Used for navigation logic in the main app
              );
            }
            if (!mounted) return;
            context.read<TransactionBloc>().add(
              TransactionEventAddSmsDraft(smsDraft: smsDraft),
            );
          }
        },
      );
    } else {
      log("SMS permissions denied or setup failed.");
    }
  }

  void _performInitialSync() {
    if (context.read<SettingsBloc>().state.model.hasLoggedIn &&
        context.read<AuthRepository>().currentUser != null) {
      context.read<TransactionBloc>().add(
        const TransactionEventCheckAndSyncPending(),
      );
      context.read<CategoryBloc>().add(
        const CategoryEventCheckAndSyncPending(),
      );
      context.read<AccountBloc>().add(const AccountEventCheckAndSyncPending());
    }
  }

  void _triggerSyncIfNecessary() {
    final now = DateTime.now();
    if (now.difference(_lastSyncTime) >= _syncInterval) {
      _performSync();
      _lastSyncTime = now;
    }
  }

  void _performSync() {
    if (context.read<AuthRepository>().currentUser != null) {
      context.read<TransactionBloc>().add(
        const TransactionEventCheckAndSyncPending(),
      );
      context.read<CategoryBloc>().add(
        const CategoryEventCheckAndSyncPending(),
      );
      context.read<AccountBloc>().add(const AccountEventCheckAndSyncPending());
    }
  }

  void _startPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _triggerSyncIfNecessary();
    });
  }

  void _stopPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _currentIndexNotifier,
        builder: (context, currentIndex, child) {
          return IndexedStack(index: currentIndex, children: _screens);
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndexNotifier: _currentIndexNotifier,
        onTap: _onTabSelected,
      ),
    );
  }
}
