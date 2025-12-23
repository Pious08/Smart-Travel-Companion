import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/auth_provider.dart';
import '../providers/destination_provider.dart';
import '../widgets/destination_card.dart';
import 'add_destination_screen.dart';
import 'destination_detail_screen.dart';
import 'settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _quickStartGuides = [
    {
      'title': 'Welcome!',
      'description': 'Your personal travel companion is ready to help you plan amazing trips.',
      'icon': '✈️',
    },
    {
      'title': 'Add Destinations',
      'description': 'Tap the + button to add your dream destinations and start planning.',
      'icon': '🗺️',
    },
    {
      'title': 'Pin Favorites',
      'description': 'Pin destinations to keep them at the top of your list for quick access.',
      'icon': '📌',
    },
    {
      'title': 'Stay Informed',
      'description': 'Get real-time weather updates and currency rates for your destinations.',
      'icon': '🌤️',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final destinationProvider = context.watch<DestinationProvider>();
    final hasDestinations = destinationProvider.destinations.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Smart Travel'),
            Text(
              'Hello, ${authProvider.username}!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await destinationProvider.loadDestinations();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Start Carousel (show if no destinations)
              if (!hasDestinations) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Quick Start Guide',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                  ),
                  items: _quickStartGuides.map((guide) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  guide['icon']!,
                                  style: const TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  guide['title']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  guide['description']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],

              // Quick Actions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.add_location_alt,
                            title: 'Add New Trip',
                            color: Colors.blue,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AddDestinationScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.map,
                            title: 'Open Maps',
                            color: Colors.green,
                            onTap: () async {
                              final url = Uri.parse('https://maps.google.com');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Pinned Destinations
              if (destinationProvider.pinnedDestinations.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Pinned Destinations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: destinationProvider.pinnedDestinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinationProvider.pinnedDestinations[index];
                    return DestinationCard(
                      destination: destination,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DestinationDetailScreen(
                              destination: destination,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],

              // All Destinations
              if (hasDestinations) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'All Destinations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: destinationProvider.destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinationProvider.destinations[index];
                    return DestinationCard(
                      destination: destination,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DestinationDetailScreen(
                              destination: destination,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],

              if (!hasDestinations)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.explore_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No destinations yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first destination to get started!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddDestinationScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Trip'),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}