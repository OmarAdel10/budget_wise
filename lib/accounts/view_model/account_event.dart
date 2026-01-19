import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:equatable/equatable.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class AccountEventFetchAll extends AccountEvent {
  const AccountEventFetchAll();

  @override
  List<Object> get props => [];
}

class AccountEventCreateAccount extends AccountEvent {
  final AccountModel model;
  const AccountEventCreateAccount({required this.model});

  @override
  List<Object> get props => [model];
}

class AccountEventEditAccount extends AccountEvent {
  final AccountModel model;
  const AccountEventEditAccount({required this.model});

  @override
  List<Object> get props => [model];
}

class AccountEventUpdateUpdatedAtField extends AccountEvent {
  final String accountId;
  final DateTime updateDate;
  const AccountEventUpdateUpdatedAtField({required this.accountId, required this.updateDate});

  @override
  List<Object> get props => [accountId, updateDate];
}

class AccountEventDeleteAccount extends AccountEvent {
  final String accountId;
  const AccountEventDeleteAccount({required this.accountId});

  @override
  List<Object> get props => [accountId];
}

class AccountEventMarkSynced extends AccountEvent {
  final String accountId;
  const AccountEventMarkSynced({required this.accountId});

  @override
  List<Object> get props => [accountId];
}

class AccountEventSyncUnsynced extends AccountEvent {
  final String accountId;
  const AccountEventSyncUnsynced({required this.accountId});

  @override
  List<Object> get props => [accountId];
}

class AccountEventUpdateBalance extends AccountEvent {
  final String accountId;
  final double amountDelta;
  const AccountEventUpdateBalance({required this.accountId, required this.amountDelta});

  @override
  List<Object> get props => [accountId, amountDelta];
}
