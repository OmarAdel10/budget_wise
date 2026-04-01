import 'package:equatable/equatable.dart';

class ExchangeRatesModel extends Equatable {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastFetched;

  const ExchangeRatesModel({
    required this.baseCurrency,
    required this.rates,
    required this.lastFetched,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates,
      'lastFetched': lastFetched.toIso8601String(),
    };
  }

  factory ExchangeRatesModel.fromMap(Map<String, dynamic> map) {
    return ExchangeRatesModel(
      baseCurrency: map['baseCurrency'] as String,
      rates: (map['rates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      lastFetched: DateTime.parse(map['lastFetched'] as String),
    );
  }

  @override
  List<Object?> get props => [baseCurrency, rates, lastFetched];
}
