import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination_model.dart';
import '../providers/destination_provider.dart';

class AddDestinationScreen extends StatefulWidget {
  const AddDestinationScreen({Key? key}) : super(key: key);

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _hotelAddressController = TextEditingController();
  final _attractionsController = TextEditingController();
  
  double _safetyRating = 3.0;
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _hotelAddressController.dispose();
    _attractionsController.dispose();
    super.dispose();
  }

  Future<void> _saveDestination() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final attractions = _attractionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final destination = Destination(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      country: _countryController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? 'https://via.placeholder.com/400x300'
          : _imageUrlController.text.trim(),
      safetyRating: _safetyRating,
      latitude: double.tryParse(_latitudeController.text) ?? 0.0,
      longitude: double.tryParse(_longitudeController.text) ?? 0.0,
      nearbyAttractions: attractions,
      isPinned: _isPinned,
      hotelAddress: _hotelAddressController.text.trim().isEmpty
          ? null
          : _hotelAddressController.text.trim(),
    );

    await context.read<DestinationProvider>().addDestination(destination);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Destination added successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Destination'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'City Name *',
                hintText: 'e.g., Paris',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'City name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Country *',
                hintText: 'e.g., France',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Country is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe what makes this destination special',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL (optional)',
                hintText: 'https://example.com/image.jpg',
                prefixIcon: const Icon(Icons.image),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Safety Rating: ${_safetyRating.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _safetyRating,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              label: _safetyRating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() => _safetyRating = value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unsafe', style: TextStyle(color: Colors.red[300])),
                Text('Very Safe', style: TextStyle(color: Colors.green[600])),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      hintText: '48.8566',
                      prefixIcon: const Icon(Icons.my_location),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      hintText: '2.3522',
                      prefixIcon: const Icon(Icons.place),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hotelAddressController,
              decoration: InputDecoration(
                labelText: 'Hotel Address (optional)',
                hintText: '123 Main St, City',
                prefixIcon: const Icon(Icons.hotel),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _attractionsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Nearby Attractions (comma-separated)',
                hintText: 'Eiffel Tower, Louvre Museum, Notre-Dame',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Pin this destination'),
              subtitle: const Text('Keep it at the top of your list'),
              value: _isPinned,
              onChanged: (value) {
                setState(() => _isPinned = value);
              },
              secondary: const Icon(Icons.push_pin),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveDestination,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save Destination',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}