part of 'currency_bloc.dart';

sealed class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class CurrencyLoadRequested extends CurrencyEvent {
  final String baseCurrency;
  final bool forceRefresh;

  const CurrencyLoadRequested({
    required this.baseCurrency,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [baseCurrency, forceRefresh];
}

class CurrencyRefreshRequested extends CurrencyEvent {
  final String baseCurrency;

  const CurrencyRefreshRequested(this.baseCurrency);

  @override
  List<Object?> get props => [baseCurrency];
}
