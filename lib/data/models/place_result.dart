class PlaceResult {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? photoReference;

  const PlaceResult({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.photoReference,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'] as Map<String, dynamic>;
    String? photoRef;
    final photos = json['photos'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final photo = photos.first as Map<String, dynamic>;
      photoRef = photo['photo_reference'] as String?;
    }
    return PlaceResult(
      id: json['place_id'] as String,
      name: json['name'] as String,
      address: (json['formatted_address'] as String?) ??
          (json['vicinity'] as String?) ??
          '',
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
      photoReference: photoRef,
    );
  }
}
