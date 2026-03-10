import 'dart:developer';

import 'package:budget_wise/auth/data/repositories/auth_repository.dart';
import 'package:budget_wise/settings/view_model/settings_view_model.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:budget_wise/subscriptions/data/repositories/subscription_repository.dart';
import 'package:budget_wise/subscriptions/data/utils/billing_utils.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_event.dart';
import 'package:budget_wise/subscriptions/view_model/subscription_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

class SubscriptionBloc extends HydratedBloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;
  final AuthRepository authRepository;
  final SettingsBloc settingsBloc;

  SubscriptionBloc({
    required this.subscriptionRepository,
    required this.authRepository,
    required this.settingsBloc,
  }) : super(const SubscriptionInitial()) {
    authRepository.authStateChanges.listen((user) {
      if (user != null && settingsBloc.state.model.hasLoggedIn) {
        add(SubscriptionsLoadRequested());
      }
    });

    on<SubscriptionsLoadRequested>((event, emit) async {
      emit(SubscriptionLoading(subscriptions: state.subscriptions));
      try {
        final remoteSubscriptions = await subscriptionRepository.fetchAllSubscriptions();
        final localMap = {for (var s in state.subscriptions) s.id: s};
        final updatedList = <SubscriptionModel>[];

        for (var remote in remoteSubscriptions) {
          final local = localMap[remote.id];
          if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
            updatedList.add(remote);
          } else {
            updatedList.add(local);
          }
          localMap.remove(remote.id);
        }
        updatedList.addAll(localMap.values);

        emit(SubscriptionLoadSuccess(subscriptions: updatedList));
      } catch (e) {
        log('Failed to load subscriptions: $e');
        emit(SubscriptionError(subscriptions: state.subscriptions, message: e.toString()));
      }
    });

    on<SubscriptionAdded>((event, emit) async {
      final user = authRepository.currentUser;
      final newSubscription = event.subscription.copyWith(
        id: event.subscription.id.isEmpty ? const Uuid().v4() : event.subscription.id,
        userId: user?.uid ?? '',
        isSynced: false,
      );

      final updatedList = [...state.subscriptions, newSubscription];
      emit(SubscriptionLoadSuccess(subscriptions: updatedList));

      if (settingsBloc.state.model.hasLoggedIn) {
        try {
          await subscriptionRepository.addSubscription(newSubscription);
          add(SubscriptionUpdated(newSubscription.copyWith(isSynced: true)));
        } catch (e) {
          log('Failed to sync added subscription: $e');
        }
      }
    });

    on<SubscriptionUpdated>((event, emit) async {
      final updatedList = state.subscriptions.map((s) {
        return s.id == event.subscription.id ? event.subscription : s;
      }).toList();

      emit(SubscriptionLoadSuccess(subscriptions: updatedList));

      if (settingsBloc.state.model.hasLoggedIn && !event.subscription.isSynced) {
        try {
          await subscriptionRepository.updateSubscription(event.subscription);
          // Recursively update to mark as synced without infinite loop
          final synced = event.subscription.copyWith(isSynced: true);
          final finalStateList = state.subscriptions.map((s) => s.id == synced.id ? synced : s).toList();
          emit(SubscriptionLoadSuccess(subscriptions: finalStateList));
        } catch (e) {
          log('Failed to sync updated subscription: $e');
        }
      }
    });

    on<SubscriptionDeleted>((event, emit) async {
      final updatedList = state.subscriptions.where((s) => s.id != event.id).toList();
      emit(SubscriptionLoadSuccess(subscriptions: updatedList));

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
    });
  }

  @override
  SubscriptionState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> list = json['subscriptions'];
      final subscriptions = list.map((e) => SubscriptionModel.fromMap(e)).toList();
      return SubscriptionLoadSuccess(subscriptions: subscriptions);
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
