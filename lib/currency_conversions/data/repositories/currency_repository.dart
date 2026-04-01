import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exchange_rates_model.dart';

class CurrencyRepository {
  static const String _cacheKey = 'currency_rates_cache';
  final SharedPreferences _prefs;

  CurrencyRepository(this._prefs);

  Future<ExchangeRatesModel?> fetchLatestRates(String baseCurrency) async {
    try {
      final url = Uri.parse(
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/${baseCurrency.toLowerCase()}.json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data[baseCurrency.toLowerCase()] as Map<String, dynamic>;

        final model = ExchangeRatesModel(
          baseCurrency: baseCurrency,
          rates: rates.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ),
          lastFetched: DateTime.now(),
        );

        await saveToCache(model);
        return model;
      }
    } catch (e) {
      log('Error fetching rates: $e');
    }
    return null;
  }

  Future<void> saveToCache(ExchangeRatesModel model) async {
    await _prefs.setString(_cacheKey, json.encode(model.toMap()));
  }

  ExchangeRatesModel? loadFromCache() {
    final cached = _prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        return ExchangeRatesModel.fromMap(json.decode(cached));
      } catch (e) {
        log('Error loading rates from cache: $e');
      }
    }
    return null;
  }

  bool shouldRefresh(ExchangeRatesModel? model) {
    if (model == null) return true;
    final diff = DateTime.now().difference(model.lastFetched);
    return diff.inHours >= 24;
  }
}
