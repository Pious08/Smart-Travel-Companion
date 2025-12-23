import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/destination_model.dart';
import '../providers/destination_provider.dart';
import '../services/weather_service.dart';
import '../services/currency_service.dart';
import '../providers/settings_provider.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({Key? key, required this.destination}) : super(key: key);

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Map<String, dynamic>? _weatherData;
  Map<String, double>? _exchangeRates;
  bool _isLoadingWeather = true;
  bool _isLoadingRates = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
    _loadExchangeRates();
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoadingWeather = true);
    final weather = WeatherService.getMockWeather(widget.destination.name);
    setState(() {
      _weatherData = weather;
      _isLoadingWeather = false;
    });
  }

  Future<void> _loadExchangeRates() async {
    setState(() => _isLoadingRates = true);
    final rates = CurrencyService.getMockExchangeRates('USD');
    setState(() {
      _exchangeRates = rates;
      _isLoadingRates = false;
    });
  }

  void _shareDestination() {
    Share.share(
      '${widget.destination.name}, ${widget.destination.country}\n\n'
      '${widget.destination.description}\n\n'
      'Safety Rating: ${widget.destination.safetyRating}/5.0',
      subject: 'Check out ${widget.destination.name}!',
    );
  }

  Future<void> _openMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${widget.destination.latitude},${widget.destination.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareDestination,
              ),
              Consumer<DestinationProvider>(
                builder: (context, provider, _) {
                  final destination = provider.destinations
                      .firstWhere((d) => d.id == widget.destination.id);
                  return IconButton(
                    icon: Icon(
                      destination.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    ),
                    onPressed: () => provider.togglePin(destination.id),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.destination.name),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.destination.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 100),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Text(
                        widget.destination.country,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.destination.safetyRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.destination.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // Weather Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                'Current Weather',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingWeather)
                            const Center(child: CircularProgressIndicator())
                          else if (_weatherData != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '${settingsProvider.convertTemperature(_weatherData!['temperature']).toStringAsFixed(1)}'
                                      '${settingsProvider.getTemperatureUnit()}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(_weatherData!['description']),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Humidity: ${_weatherData!['humidity']}%'),
                                    Text('Wind: ${_weatherData!['windSpeed']} m/s'),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Currency Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.attach_money, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'Exchange Rates (from USD)',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingRates)
                            const Center(child: CircularProgressIndicator())
                          else if (_exchangeRates != null)
                            Column(
                              children: _exchangeRates!.entries.take(4).map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('1 USD → ${entry.key}'),
                                      Text(
                                        '${CurrencyService.getCurrencySymbol(entry.key)}'
                                        '${entry.value.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Map Button
                  if (widget.destination.latitude != 0 && widget.destination.longitude != 0)
                    ElevatedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.map),
                      label: const Text('View on Map'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Nearby Attractions
                  if (widget.destination.nearbyAttractions.isNotEmpty) ...[
                    Text(
                      'Nearby Attractions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.destination.nearbyAttractions.map((attraction) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.place),
                          title: Text(attraction),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}