import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/destination_model.dart';

class DestinationProvider extends ChangeNotifier {
  List<Destination> _destinations = [];
  List<Destination> _pinnedDestinations = [];

  List<Destination> get destinations => _destinations;
  List<Destination> get pinnedDestinations => _pinnedDestinations;

  DestinationProvider() {
    loadDestinations();
  }

  // Load destinations from local storage
  Future<void> loadDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final destinationsJson = prefs.getString('destinations');
    
    if (destinationsJson != null) {
      final List<dynamic> decoded = json.decode(destinationsJson);
      _destinations = decoded.map((item) => Destination.fromJson(item)).toList();
      _pinnedDestinations = _destinations.where((d) => d.isPinned).toList();
      notifyListeners();
    }
  }

  // Save destinations to local storage
  Future<void> saveDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final destinationsJson = json.encode(_destinations.map((d) => d.toJson()).toList());
    await prefs.setString('destinations', destinationsJson);
  }

  // Add new destination
  Future<void> addDestination(Destination destination) async {
    _destinations.add(destination);
    if (destination.isPinned) {
      _pinnedDestinations.add(destination);
    }
    
    // Track frequency for admin analytics
    await _trackDestinationFrequency(destination.name);
    
    await saveDestinations();
    notifyListeners();
  }

  // Update destination
  Future<void> updateDestination(Destination destination) async {
    final index = _destinations.indexWhere((d) => d.id == destination.id);
    if (index != -1) {
      _destinations[index] = destination;
      _pinnedDestinations = _destinations.where((d) => d.isPinned).toList();
      await saveDestinations();
      notifyListeners();
    }
  }

  // Delete destination
  Future<void> deleteDestination(String id) async {
    _destinations.removeWhere((d) => d.id == id);
    _pinnedDestinations = _destinations.where((d) => d.isPinned).toList();
    await saveDestinations();
    notifyListeners();
  }

  // Toggle pin status
  Future<void> togglePin(String id) async {
    final index = _destinations.indexWhere((d) => d.id == id);
    if (index != -1) {
      _destinations[index].isPinned = !_destinations[index].isPinned;
      _pinnedDestinations = _destinations.where((d) => d.isPinned).toList();
      await saveDestinations();
      notifyListeners();
    }
  }

  // Track destination frequency for analytics
  Future<void> _trackDestinationFrequency(String destinationName) async {
    final prefs = await SharedPreferences.getInstance();
    final frequencyJson = prefs.getString('destination_frequency') ?? '{}';
    final Map<String, dynamic> frequency = json.decode(frequencyJson);
    
    frequency[destinationName] = (frequency[destinationName] ?? 0) + 1;
    
    await prefs.setString('destination_frequency', json.encode(frequency));
  }

  // Get destination frequency (for admin)
  Future<Map<String, int>> getDestinationFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final frequencyJson = prefs.getString('destination_frequency') ?? '{}';
    final Map<String, dynamic> frequency = json.decode(frequencyJson);
    
    return frequency.map((key, value) => MapEntry(key, value as int));
  }

  // Check if user has Japan in bucket list (for targeted notifications)
  bool hasJapanInBucketList() {
    return _destinations.any((d) => 
      d.name.toLowerCase().contains('japan') || 
      d.name.toLowerCase().contains('tokyo') ||
      d.name.toLowerCase().contains('kyoto') ||
      d.name.toLowerCase().contains('osaka')
    );
  }
}