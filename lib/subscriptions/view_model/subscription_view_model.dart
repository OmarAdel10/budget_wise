import 'dart:developer';

import 'package:budget_wise/accounts/view_model/account_view_model.dart';

import 'package:budget_wise/transaction/data/models/transaction_model.dart';
import 'package:budget_wise/transaction/view_model/transaction_event.dart';
import 'package:budget_wise/transaction/view_model/transaction_view_model.dart';
import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/subscriptions/data/models/billing_cycle.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/repositories/subscription_repository.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:budget_wise/notifications/data/repositories/notification_repository.dart';

class SubscriptionBloc
    extends HydratedBloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;
  final AuthRepository authRepository;
  final SettingsBloc settingsBloc;
  final AccountBloc accountBloc;
  final TransactionBloc transactionBloc;

  SubscriptionBloc({
    required this.subscriptionRepository,
    required this.authRepository,
    required this.settingsBloc,
    required this.accountBloc,
    required this.transactionBloc,
  }) : super(const SubscriptionInitial()) {
    authRepository.authStateChanges.listen((user) {
      if (user != null && settingsBloc.state.model.hasLoggedIn) {
        add(SubscriptionsLoadRequested());
      }
    });

    settingsBloc.stream.listen((settingsState) {
      final isEnabled =
          settingsState.model.allNotificationsEnabled &&
          settingsState.model.subscriptionNotificationsEnabled;
      if (isEnabled) {
        // Reschedule all when re-enabled
        for (var sub in state.subscriptions) {
          _scheduleNotification(sub);
        }
      } else {
        // Handled by SettingsBloc range cancellation
      }
    });

    on<SubscriptionsLoadRequested>((event, emit) async {
      emit(
        SubscriptionLoading(
          subscriptions: state.subscriptions,
          totalMonthlySpend: state.totalMonthlySpend,
        ),
      );
      try {
        final remoteSubscriptions = await subscriptionRepository
            .fetchAllSubscriptions();
        final localMap = {for (var s in state.subscriptions) s.id: s};
        final updatedList = <SubscriptionModel>[];

        for (var remote in remoteSubscriptions) {
          final local = localMap[remote.id];
          if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
            updatedList.add(remote);
            _scheduleNotification(remote);
          } else {
            updatedList.add(local);
          }
          localMap.remove(remote.id);
        }
        updatedList.addAll(localMap.values);

        emit(
          SubscriptionLoadSuccess(
            subscriptions: updatedList,
            totalMonthlySpend: _calculateTotalMonthlySpend(updatedList),
          ),
        );
      } catch (e) {
        log('Failed to load subscriptions: $e');
        emit(
          SubscriptionError(
            subscriptions: state.subscriptions,
            totalMonthlySpend: state.totalMonthlySpend,
            message: e.toString(),
          ),
        );
      }
    });

    on<SubscriptionAdded>((event, emit) async {
      final userId = authRepository.currentUser?.uid ?? '';
      final newSubscription = event.subscription.copyWith(
        id: event.subscription.id.isEmpty
            ? const Uuid().v4()
            : event.subscription.id,
        userId: userId,
        isSynced: false,
      );

      final updatedList = [...state.subscriptions, newSubscription];
      _scheduleNotification(newSubscription);
      emit(
        SubscriptionLoadSuccess(
          subscriptions: updatedList,
          totalMonthlySpend: _calculateTotalMonthlySpend(updatedList),
        ),
      );

      if (settingsBloc.state.model.hasLoggedIn) {
        try {
          await subscriptionRepository.addSubscription(newSubscription);
          add(SubscriptionUpdated(newSubscription.copyWith(isSynced: true)));
        } catch (e) {
          log('Failed to sync added subscription: $e');
        }
      }
    });

    on<SubscriptionBulkCreate>((event, emit) async {
      try {
        if (event.subscriptions.isEmpty) {
          event.completer?.complete();
          return;
        }

        final userId = authRepository.currentUser?.uid ?? '';
        final normalizedSubscriptions = <SubscriptionModel>[];
        final seenKeys = <String>{};

        for (final subscription in event.subscriptions) {
          final normalized = subscription.copyWith(
            id: subscription.id.isEmpty
                ? const Uuid().v4()
                : subscription.id,
            userId: userId,
            isSynced: false,
          );

          if (seenKeys.add(_subscriptionImportKey(normalized))) {
            normalizedSubscriptions.add(normalized);
          }
        }

        if (normalizedSubscriptions.isEmpty) {
          event.completer?.complete();
          return;
        }

        final updatedList = [...normalizedSubscriptions, ...state.subscriptions];
        for (final subscription in normalizedSubscriptions) {
          _scheduleNotification(subscription);
        }

        emit(
          SubscriptionLoadSuccess(
            subscriptions: updatedList,
            totalMonthlySpend: _calculateTotalMonthlySpend(updatedList),
          ),
        );

        if (settingsBloc.state.model.hasLoggedIn &&
            authRepository.currentUser != null) {
          final syncedSubscriptions = normalizedSubscriptions
              .map((subscription) => subscription.copyWith(isSynced: true))
              .toList();
          await subscriptionRepository.bulkAddSubscriptions(
            syncedSubscriptions,
          );

          final syncedIds = syncedSubscriptions.map((s) => s.id).toSet();
          final finalList = updatedList.map((subscription) {
            if (syncedIds.contains(subscription.id)) {
              return subscription.copyWith(isSynced: true);
            }
            return subscription;
          }).toList();

          emit(
            SubscriptionLoadSuccess(
              subscriptions: finalList,
              totalMonthlySpend: _calculateTotalMonthlySpend(finalList),
            ),
          );
        }

        event.completer?.complete();
      } catch (e) {
        event.completer?.completeError(e);
        log('Failed to bulk import subscriptions: $e');
        emit(
          SubscriptionError(
            subscriptions: state.subscriptions,
            totalMonthlySpend: state.totalMonthlySpend,
            message: e.toString(),
          ),
        );
      }
    });

    on<SubscriptionUpdated>((event, emit) async {
      final updatedSubscription = event.subscription.copyWith(isSynced: false);
      final updatedList = state.subscriptions.map((sub) {
        return sub.id == updatedSubscription.id ? updatedSubscription : sub;
      }).toList();

      _cancelNotification(updatedSubscription.id);
      _scheduleNotification(updatedSubscription);

      emit(
        SubscriptionLoadSuccess(
          subscriptions: updatedList,
          totalMonthlySpend: _calculateTotalMonthlySpend(updatedList),
        ),
      );

      if (settingsBloc.state.model.hasLoggedIn &&
          !event.subscription.isSynced) {
        try {
          await subscriptionRepository.updateSubscription(updatedSubscription);
          // Recursively update to mark as synced without infinite loop
          final synced = event.subscription.copyWith(isSynced: true);
          final finalStateList = state.subscriptions
              .map((s) => s.id == synced.id ? synced : s)
              .toList();
          emit(
            SubscriptionLoadSuccess(
              subscriptions: finalStateList,
              totalMonthlySpend: _calculateTotalMonthlySpend(finalStateList),
            ),
          );
        } catch (e) {
          log('Failed to sync updated subscription: $e');
        }
      }
    });

    on<SubscriptionDeleted>((event, emit) async {
      _cancelNotification(event.id);
      final updatedList = state.subscriptions
          .where((s) => s.id != event.id)
          .toList();
      emit(
        SubscriptionLoadSuccess(
          subscriptions: updatedList,
          totalMonthlySpend: _calculateTotalMonthlySpend(updatedList),
        ),
      );

      if (settingsBloc.state.model.hasLoggedIn) {
        try {
          await subscriptionRepository.deleteSubscription(event.id);
        } catch (e) {
          log('Failed to delete remote subscription: $e');
        }
      }
    });

    on<SubscriptionPaid>((event, emit) {
      final sub = state.subscriptions.firstWhere((s) => s.id == event.id);
      final nextDate = BillingUtils.calculateNextBillingDate(
        lastBillingDate: sub.nextBillingDate,
        billingDay: sub.billingDay,
        cycle: sub.billingCycle,
      );

      final updatedSub = sub.copyWith(
        lastPaidDate: DateTime.now(),
        nextBillingDate: nextDate,
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      add(SubscriptionUpdated(updatedSub));

      // 1. Create a transaction for this payment
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        userId: authRepository.currentUser?.uid ?? '',
        transactionTitle: '${sub.name} Payment',
        transactionAmount: sub.amount,
        transactionCurrency: sub.currency,
        categoryId: sub.categoryId,
        accountId: sub.accountId,
        transactionDate: DateTime.now(),
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        transactionNotes: event.l10n.subNote(
          sub.name,
          DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
        ),
      );

      // 2. Add transaction and update account balance
      transactionBloc.add(
        TransactionEventCreateTransaction(
          transaction,
          convertedAmount: event.convertedAmount,
          toastCallback: event.toastCallback,
        ),
      );
    });
  }

  void _scheduleNotification(SubscriptionModel sub) async {
    final isEnabled =
        settingsBloc.state.model.allNotificationsEnabled &&
        settingsBloc.state.model.subscriptionNotificationsEnabled;
    if (!isEnabled || sub.inActive) return;

    final id =
        NotificationRepository.subsRangeStart + sub.id.hashCode.abs() % 1000;

    await NotificationRepository.scheduledNotification(
      channelId: 'subscription_alerts',
      channelName: 'Subscription Reminders',
      channelDescription: 'Alerts for upcoming subscriptions',
      id: id,
      title: 'Upcoming Subscription',
      body: 'Your ${sub.name} subscription of ${sub.amount} is due tomorrow!',
      scheduledDate: sub.nextBillingDate.subtract(const Duration(days: 1)),
      payload: 'subscription_${sub.id}',
    );
  }

  void _cancelNotification(String subId) async {
    final id =
        NotificationRepository.subsRangeStart + subId.hashCode.abs() % 1000;
    await NotificationRepository.cancelNotificationById(id);
  }

  double _calculateTotalMonthlySpend(List<SubscriptionModel> subscriptions) {
    double total = 0.0;
    for (final sub in subscriptions) {
      if (sub.inActive) continue;

      switch (sub.billingCycle) {
        case BillingCycle.weekly:
          total += sub.amount * 52 / 12;
        case BillingCycle.monthly:
          total += sub.amount;
        case BillingCycle.quarterly:
          total += sub.amount / 3;
        case BillingCycle.halfYearly:
          total += sub.amount / 6;
        case BillingCycle.yearly:
          total += sub.amount / 12;
      }
    }
    return total;
  }

  String _subscriptionImportKey(SubscriptionModel subscription) {
    final dateKey =
        DateFormat('yyyy-MM-dd').format(subscription.nextBillingDate);
    return [
      subscription.name.toLowerCase(),
      subscription.amount.toStringAsFixed(2),
      subscription.currency.toLowerCase(),
      subscription.categoryId.toLowerCase(),
      subscription.accountId.toLowerCase(),
      subscription.billingCycle.name,
      dateKey,
    ].join('|');
  }

  @override
  SubscriptionState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> list = json['subscriptions'];
      final subscriptions = list
          .map((e) => SubscriptionModel.fromMap(e))
          .toList();
      return SubscriptionLoadSuccess(
        subscriptions: subscriptions,
        totalMonthlySpend: _calculateTotalMonthlySpend(subscriptions),
      );
    } catch (e) {
      log('Error deserializing SubscriptionState: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SubscriptionState state) {
    return {
      'subscriptions': state.subscriptions.map((e) => e.toMap()).toList(),
    };
  }
}
