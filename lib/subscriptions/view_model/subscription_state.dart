import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:equatable/equatable.dart';

abstract class SubscriptionState extends Equatable {
  final List<SubscriptionModel> subscriptions;
  final double totalMonthlySpend;
  final bool isLoading;
  final String? errorMessage;

  const SubscriptionState({
    required this.subscriptions,
    this.totalMonthlySpend = 0.0,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    subscriptions,
    totalMonthlySpend,
    isLoading,
    errorMessage,
  ];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial() : super(subscriptions: const []);
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading({
    required super.subscriptions,
    super.totalMonthlySpend,
  }) : super(isLoading: true);
}

class SubscriptionLoadSuccess extends SubscriptionState {
  const SubscriptionLoadSuccess({
    required super.subscriptions,
    super.totalMonthlySpend,
  });
}

class SubscriptionError extends SubscriptionState {
  const SubscriptionError({
    required super.subscriptions,
    super.totalMonthlySpend,
    required String message,
  }) : super(errorMessage: message);
}
