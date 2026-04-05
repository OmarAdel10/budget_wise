import 'dart:convert';
import 'dart:developer';
import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';
import 'package:workmanager/workmanager.dart';
import 'package:budget_wise/savings/data/models/savings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundTasks {
  static const String morningCheckTask = "morningCheckTask";
  static const String periodicBalanceCheckTask = "periodicBalanceCheckTask";

  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static void scheduleTasks() {
    // Periodic check every 3 hours
    Workmanager().registerPeriodicTask(
      "1",
      periodicBalanceCheckTask,
      frequency: const Duration(hours: 3),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    // Morning check (One-off that schedules itself for tomorrow)
    _scheduleNextMorningCheck();
  }

  static void _scheduleNextMorningCheck() {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0); // 9:00 AM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final delay = scheduledDate.difference(now);

    Workmanager().registerOneOffTask(
      "morning_check_unique",
      morningCheckTask,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if notifications are enabled globally
      final allEnabled = prefs.getBool('all_notifications_enabled') ?? true;
      final savingsEnabled = prefs.getBool('savings_notifications_enabled') ?? true;
      
      if (!allEnabled || !savingsEnabled) return true;

      // Load data from snapshots
      final accountsJson = prefs.getString('bg_accounts_snapshot');
      final savingsJson = prefs.getString('bg_savings_snapshot');

      if (accountsJson == null || savingsJson == null) {
        log('Background task: No snapshots found.');
        return true; 
      }

      final List<dynamic> accountsListRaw = jsonDecode(accountsJson);
      final List<dynamic> savingsListRaw = jsonDecode(savingsJson);

      final accounts = accountsListRaw.map((e) => AccountModel.fromMap(e)).toList();
      final goals = savingsListRaw.map((e) => SavingsModel.fromMap(e)).toList();

      if (task == BackgroundTasks.morningCheckTask) {
        await _handleMorningCheck(goals, accounts);
        
        // Reschedule for next day
        final now = DateTime.now();
        final scheduledDate = DateTime(now.year, now.month, now.day, 9, 0).add(const Duration(days: 1));
        final delay = scheduledDate.difference(now);
        await Workmanager().registerOneOffTask(
          "morning_check_unique",
          BackgroundTasks.morningCheckTask,
          initialDelay: delay,
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      } else if (task == BackgroundTasks.periodicBalanceCheckTask) {
        await _handlePeriodicCheck(goals, accounts);
      }

      return true;
    } catch (e) {
      log('Background task error: $e');
      return false;
    }
  });
}

Future<void> _handleMorningCheck(List<SavingsModel> goals, List<AccountModel> accounts) async {
  final accountsMap = {for (final acc in accounts) acc.id: acc};
  List<String> lowBalanceAccounts = [];
  List<String> behindScheduleGoals = [];
  String firstSourceId = '';
  double firstRequiredAmount = 0.0;

  for (final goal in goals) {
    if (goal.isCompleted) continue;
    
    // 1. Low Balance Check
    final todayIndex = DateTime.now().difference(goal.createdAt).inDays + 1;
    if (!goal.completedDays.contains(todayIndex)) {
      final dailyAmount = goal.getAmountForDay(todayIndex);
      final sourceAccount = accountsMap[goal.sourceAccountId];
      
      if (sourceAccount != null && sourceAccount.balance < dailyAmount) {
        if (!lowBalanceAccounts.contains(sourceAccount.title)) {
          lowBalanceAccounts.add(sourceAccount.title);
        }
        if (firstSourceId.isEmpty) {
          firstSourceId = sourceAccount.id;
          firstRequiredAmount = dailyAmount;
        }
      }
    }

    // 2. Behind Schedule Check
    if (goal.isBehindSchedule) {
      behindScheduleGoals.add(goal.name);
    }
  }

  // Dispatch aggregated notifications
  if (lowBalanceAccounts.isNotEmpty) {
    await NotificationRepository.instantNotification(
      channelId: 'saving_alerts',
      channelName: 'Savings Alerts',
      channelDescription: 'Alerts for savings goals',
      id: 999,
      title: 'Action Needed: Savings',
      body: 'Your balance in ${lowBalanceAccounts.join(", ")} is low. Update it to stay on track!',
      payload: 'add_transaction_with_context|$firstSourceId|$firstRequiredAmount',
    );
  }

  if (behindScheduleGoals.isNotEmpty) {
    await NotificationRepository.instantNotification(
      channelId: 'saving_alerts',
      channelName: 'Savings Alerts',
      channelDescription: 'Alerts for savings goals',
      id: 998,
      title: 'Savings Progress Update',
      body: 'You are slightly behind schedule on: ${behindScheduleGoals.join(", ")}. Every small bit counts!',
      payload: 'nav_savings',
    );
  }
}

Future<void> _handlePeriodicCheck(List<SavingsModel> goals, List<AccountModel> accounts) async {
  final prefs = await SharedPreferences.getInstance();
  final blockedGoals = prefs.getStringList('blocked_saving_goals') ?? [];
  final newBlockedGoals = <String>[];
  final accountsMap = {for (var acc in accounts) acc.id: acc};

  for (var goal in goals) {
    if (goal.isCompleted) continue;

    final todayIndex = DateTime.now().difference(goal.createdAt).inDays + 1;
    if (goal.completedDays.contains(todayIndex)) continue;

    final dailyAmount = goal.getAmountForDay(todayIndex);
    final sourceAccount = accountsMap[goal.sourceAccountId];
    
    if (sourceAccount != null) {
      if (sourceAccount.balance >= dailyAmount) {
        if (blockedGoals.contains(goal.id)) {
          // Funds are now available!
          await NotificationRepository.instantNotification(
            channelId: 'saving_alerts',
            channelName: 'Savings Alerts',
            channelDescription: 'Alerts for savings goals',
            id: goal.createdAt.millisecondsSinceEpoch ~/1000,
            title: 'Funds Available!',
            body: "Your balance in ${sourceAccount.title} is now enough for your '${goal.name}' goal. Mark it as complete!",
            payload: 'saving_goal_${goal.id}',
          );
        }
      } else {
        newBlockedGoals.add(goal.id);
      }
    }
  }

  await prefs.setStringList('blocked_saving_goals', newBlockedGoals);
}
