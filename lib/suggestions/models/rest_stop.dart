class RestStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double? rating;
  final bool? openNow;
  final String? address;
  final String type;
  final String? openingHours;

  const RestStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.rating,
    this.openNow,
    this.address,
    required this.type,
    this.openingHours
  });
}