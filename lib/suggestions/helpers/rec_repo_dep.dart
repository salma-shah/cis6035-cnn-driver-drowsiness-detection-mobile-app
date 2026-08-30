import 'package:sleepy_driver/location/services/location_service.dart';
import 'package:sleepy_driver/suggestions/helpers/route_helper.dart';
import 'package:sleepy_driver/suggestions/recommendation_engine.dart';
import 'package:sleepy_driver/suggestions/repos/rec_repo.dart';
import 'package:sleepy_driver/suggestions/services/overpass_service.dart';

RecommendationRepo createRecommendationRepo() {
  final locationService = LocationService();
  final overpassService = OverpassService();
  final recommendationEngine = RecommendationEngine();
  final routeHelper = RouteHelper();

  return RecommendationRepo(
    locationService: locationService, 
    overpassService: overpassService, 
    recommendationEngine: recommendationEngine,
    routeHelper: routeHelper);
}