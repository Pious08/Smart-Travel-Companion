class Destination {
  final String id;
  final String name;
  final String country;
  final String description;
  final String imageUrl;
  final double safetyRating;
  final double latitude;
  final double longitude;
  final List<String> nearbyAttractions;
  bool isPinned;
  final String? hotelAddress;

  Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.safetyRating,
    required this.latitude,
    required this.longitude,
    required this.nearbyAttractions,
    this.isPinned = false,
    this.hotelAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'description': description,
      'imageUrl': imageUrl,
      'safetyRating': safetyRating,
      'latitude': latitude,
      'longitude': longitude,
      'nearbyAttractions': nearbyAttractions,
      'isPinned': isPinned,
      'hotelAddress': hotelAddress,
    };
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      safetyRating: json['safetyRating'].toDouble(),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      nearbyAttractions: List<String>.from(json['nearbyAttractions']),
      isPinned: json['isPinned'] ?? false,
      hotelAddress: json['hotelAddress'],
    );
  }

  Destination copyWith({
    String? id,
    String? name,
    String? country,
    String? description,
    String? imageUrl,
    double? safetyRating,
    double? latitude,
    double? longitude,
    List<String>? nearbyAttractions,
    bool? isPinned,
    String? hotelAddress,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      safetyRating: safetyRating ?? this.safetyRating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nearbyAttractions: nearbyAttractions ?? this.nearbyAttractions,
      isPinned: isPinned ?? this.isPinned,
      hotelAddress: hotelAddress ?? this.hotelAddress,
    );
  }
}