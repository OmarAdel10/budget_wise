import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:equatable/equatable.dart';

abstract class SubscriptionState extends Equatable {
  final List<SubscriptionModel> subscriptions;
  final bool isLoading;
  final String? errorMessage;

  const SubscriptionState({
    required this.subscriptions,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [subscriptions, isLoading, errorMessage];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial() : super(subscriptions: const []);
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading({required super.subscriptions}) : super(isLoading: true);
}

class SubscriptionLoadSuccess extends SubscriptionState {
  const SubscriptionLoadSuccess({required super.subscriptions});
}

class SubscriptionError extends SubscriptionState {
  const SubscriptionError({
    required super.subscriptions,
    required String message,
  }) : super(errorMessage: message);
}
