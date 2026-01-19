import 'package:budget_wise/accounts/data/models/account_model.dart';
import 'package:equatable/equatable.dart';

abstract class AccountState extends Equatable {
  final double netWorth;
  final List<AccountModel> accountsList;
  const AccountState({required this.accountsList, required this.netWorth});

  @override
  List<Object> get props => [accountsList];
}

class AccountStateInitial extends AccountState {
  const AccountStateInitial({
    required super.accountsList,
    required super.netWorth,
  });

  @override
  List<Object> get props => [accountsList, netWorth];
}

class AccountStateSuccess extends AccountState {
  const AccountStateSuccess({
    required super.accountsList,
    required super.netWorth,
  });

  @override
  List<Object> get props => [accountsList, netWorth];
}

class AccountStateError extends AccountState {
  final String message;
  const AccountStateError({
    required this.message,
    required super.accountsList,
    required super.netWorth,
  });

  @override
  List<Object> get props => [message, accountsList, netWorth];
}
