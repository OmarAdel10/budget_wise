import 'package:budget_wise/l10n/app_localizations.dart';
import 'package:budget_wise/subscriptions/data/models/subscription_model.dart';
import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionsLoadRequested extends SubscriptionEvent {}

class SubscriptionAdded extends SubscriptionEvent {
  final SubscriptionModel subscription;
  const SubscriptionAdded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionUpdated extends SubscriptionEvent {
  final SubscriptionModel subscription;
  const SubscriptionUpdated(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionDeleted extends SubscriptionEvent {
  final String id;
  const SubscriptionDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}

class SubscriptionPaid extends SubscriptionEvent {
  final String id;
  final double? convertedAmount;
  final AppLocalizations l10n;
  const SubscriptionPaid(this.id, {this.convertedAmount, required this.l10n});

  @override
  List<Object?> get props => [id, convertedAmount, l10n];
}
