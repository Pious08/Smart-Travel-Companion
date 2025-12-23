import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Using ExchangeRate API (free tier available)
  static const String _apiKey = 'ab1d440014d3eacb462c6446';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  static Future<Map<String, dynamic>?> getExchangeRate(
    String baseCurrency,
    String targetCurrency,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/$_apiKey/pair/$baseCurrency/$targetCurrency');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'rate': data['conversion_rate'],
          'base': baseCurrency,
          'target': targetCurrency,
          'lastUpdated': data['time_last_update_utc'],
        };
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
    }
    return null;
  }

  static Future<Map<String, double>?> getMultipleRates(
    String baseCurrency,
    List<String> targetCurrencies,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/$_apiKey/latest/$baseCurrency');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> rates = data['conversion_rates'];
        
        Map<String, double> filteredRates = {};
        for (var currency in targetCurrencies) {
          if (rates.containsKey(currency)) {
            filteredRates[currency] = rates[currency].toDouble();
          }
        }
        
        return filteredRates;
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
    }
    return null;
  }

  // Mock exchange rates for demo
  static Map<String, double> getMockExchangeRates(String baseCurrency) {
    final rates = {
      'USD': {'EUR': 0.92, 'GBP': 0.79, 'JPY': 149.50, 'INR': 83.12},
      'EUR': {'USD': 1.09, 'GBP': 0.86, 'JPY': 162.89, 'INR': 90.52},
      'GBP': {'USD': 1.27, 'EUR': 1.16, 'JPY': 189.23, 'INR': 105.23},
      'JPY': {'USD': 0.0067, 'EUR': 0.0061, 'GBP': 0.0053, 'INR': 0.56},
      'INR': {'USD': 0.012, 'EUR': 0.011, 'GBP': 0.0095, 'JPY': 1.80},
    };

    return rates[baseCurrency] ?? {'USD': 1.0};
  }

  // Get currency symbol
  static String getCurrencySymbol(String currencyCode) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'INR': '₹',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'CHF': 'Fr',
      'CNY': '¥',
    };

    return symbols[currencyCode] ?? currencyCode;
  }
}