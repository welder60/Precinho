class PlaceResult {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'] as Map<String, dynamic>;
    return PlaceResult(
      id: json['place_id'] as String,
      name: json['name'] as String,
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
    );
  }
}
