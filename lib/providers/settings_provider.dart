import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _travelAlertsEnabled = true;
  bool _promotionalNotifications = true;
  bool _metricUnits = true; // true for Celsius, false for Fahrenheit
  bool _betaFeaturesEnabled = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get travelAlertsEnabled => _travelAlertsEnabled;
  bool get promotionalNotifications => _promotionalNotifications;
  bool get metricUnits => _metricUnits;
  bool get betaFeaturesEnabled => _betaFeaturesEnabled;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _travelAlertsEnabled = prefs.getBool('travelAlertsEnabled') ?? true;
    _promotionalNotifications = prefs.getBool('promotionalNotifications') ?? true;
    _metricUnits = prefs.getBool('metricUnits') ?? true;
    _betaFeaturesEnabled = prefs.getBool('betaFeaturesEnabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> toggleTravelAlerts() async {
    _travelAlertsEnabled = !_travelAlertsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('travelAlertsEnabled', _travelAlertsEnabled);
    notifyListeners();
  }

  Future<void> togglePromotionalNotifications() async {
    _promotionalNotifications = !_promotionalNotifications;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promotionalNotifications', _promotionalNotifications);
    notifyListeners();
  }

  Future<void> toggleMetricUnits() async {
    _metricUnits = !_metricUnits;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('metricUnits', _metricUnits);
    notifyListeners();
  }

  Future<void> toggleBetaFeatures() async {
    _betaFeaturesEnabled = !_betaFeaturesEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('betaFeaturesEnabled', _betaFeaturesEnabled);
    notifyListeners();
  }

  String getTemperatureUnit() {
    return _metricUnits ? '°C' : '°F';
  }

  double convertTemperature(double celsius) {
    return _metricUnits ? celsius : (celsius * 9 / 5) + 32;
  }
}