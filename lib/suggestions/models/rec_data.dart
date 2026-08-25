import 'package:sleepy_driver/location/models/driver_location.dart';
import 'package:sleepy_driver/suggestions/models/rest_stop.dart';

class RecommendationData {
  final DriverLocation currentLocation;
  final List<RestStop> stops;

  const RecommendationData({
    required this.currentLocation,
    required this.stops,
  });
}