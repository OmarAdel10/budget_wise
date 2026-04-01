part of 'currency_bloc.dart';

sealed class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

final class CurrencyInitial extends CurrencyState {}

final class CurrencyLoading extends CurrencyState {}

final class CurrencyLoadSuccess extends CurrencyState {
  final ExchangeRatesModel rates;

  const CurrencyLoadSuccess(this.rates);

  @override
  List<Object?> get props => [rates];
}

final class CurrencyError extends CurrencyState {
  final String message;

  const CurrencyError(this.message);

  @override
  List<Object?> get props => [message];
}
