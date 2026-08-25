import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/location/models/driver_location.dart';
import 'package:sleepy_driver/location/services/location_service.dart';
import 'package:sleepy_driver/suggestions/helpers/route_helper.dart';
import 'package:sleepy_driver/suggestions/models/rec_data.dart';
import 'package:sleepy_driver/suggestions/models/rest_stop.dart';
import 'package:sleepy_driver/suggestions/models/route_result.dart';
import 'package:sleepy_driver/suggestions/recommendation_engine.dart';
import 'package:sleepy_driver/suggestions/services/overpass_service.dart';

class RecommendationRepo {
  final LocationService locationService;
  final OverpassService overpassService;
  final RecommendationEngine recommendationEngine;
  final RouteHelper routeHelper;

  RecommendationRepo({
    required this.locationService,
    required this.overpassService,
    required this.recommendationEngine,
    required this.routeHelper
  });

Future<RouteResult> getRouteToStop(
  RestStop stop,
) async {
  final position =
      await locationService.getCurrentPosition();

  return routeHelper.getRoute(
    startLatitude: position.latitude,
    startLongitude: position.longitude,
    destinationLatitude: stop.latitude,
    destinationLongitude: stop.longitude,
  );
}

Future<RecommendationData> getRecommendations({
  required FatigueSeverity severity,
  double radiusMeters = 5000,
}) async {
  final position =
      await locationService.getCurrentPosition();

  final location = DriverLocation(
    latitude: position.latitude,
    longitude: position.longitude,
  );

  final stops =
      await overpassService.findNearbyRestStops(
    location: location,
    radiusMeters: radiusMeters,
  );

  final recommendations =
      recommendationEngine.recommend(
    stops: stops,
    severity: severity,
  );

  return RecommendationData(
    currentLocation: location,
    stops: recommendations,
  );
}
}