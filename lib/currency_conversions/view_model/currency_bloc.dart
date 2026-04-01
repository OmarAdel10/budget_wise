import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/exchange_rates_model.dart';
import '../data/repositories/currency_repository.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyRepository _repository;

  CurrencyBloc(this._repository) : super(CurrencyInitial()) {
    on<CurrencyLoadRequested>(_onLoadRequested);
    on<CurrencyRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    CurrencyLoadRequested event,
    Emitter<CurrencyState> emit,
  ) async {
    final cached = _repository.loadFromCache();

    if (cached != null &&
        event.baseCurrency == cached.baseCurrency &&
        !event.forceRefresh) {
      emit(CurrencyLoadSuccess(cached));
      if (_repository.shouldRefresh(cached)) {
        add(CurrencyRefreshRequested(event.baseCurrency));
      }
    } else {
      emit(CurrencyLoading());
      final rates = await _repository.fetchLatestRates(event.baseCurrency);
      if (rates != null) {
        emit(CurrencyLoadSuccess(rates));
      } else if (cached != null) {
        emit(CurrencyLoadSuccess(cached));
      } else {
        emit(const CurrencyError('Failed to fetch currency rates'));
      }
    }
  }

  Future<void> _onRefreshRequested(
    CurrencyRefreshRequested event,
    Emitter<CurrencyState> emit,
  ) async {
    final rates = await _repository.fetchLatestRates(event.baseCurrency);
    if (rates != null) {
      emit(CurrencyLoadSuccess(rates));
    }
  }

  double convert({
    required double amount,
    required String from,
    required String to,
    double margin = 0.0,
  }) {
    if (state is! CurrencyLoadSuccess) return amount;
    final rates = (state as CurrencyLoadSuccess).rates.rates;

    final fromRate = rates[from.toLowerCase()];
    final toRate = rates[to.toLowerCase()];

    if (fromRate == null || toRate == null) return amount;

    // Calculation:
    // 1. Convert source amount to USD (base of API)
    // USD_amount = amount / fromRate
    // 2. Convert USD amount to target currency
    // target_amount = USD_amount * toRate

    final usdAmount = amount / fromRate;
    var result = usdAmount * toRate;

    if (margin != 0) {
      result = result * (1 + (margin / 100));
    }

    return result;
  }
}
