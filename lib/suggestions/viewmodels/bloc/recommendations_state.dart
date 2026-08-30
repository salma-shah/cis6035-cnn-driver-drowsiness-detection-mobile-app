import 'package:latlong2/latlong.dart';
import 'package:sleepy_driver/suggestions/models/rest_stop.dart';

enum RecommendationStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class RecommendationState {
  final RecommendationStatus status;
  final List<RestStop> recommendations;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? errorMessage;
  final List<LatLng> routePoints;
  final double? routeDistanceKm;
  final double? routeDurationMinutes;

  const RecommendationState({
     this.status = RecommendationStatus.initial,
    this.recommendations = const [],
    this.currentLatitude,
    this.currentLongitude,
    this.routePoints = const [],
    this.routeDistanceKm,
    this.routeDurationMinutes,
    this.errorMessage,
  });

  RecommendationState copyWith({
    RecommendationStatus? status,
    List<RestStop>? recommendations,
    double? currentLatitude,
    double? currentLongitude,
    String? errorMessage,
     List<LatLng>? routePoints,
    double? routeDistanceKm,
    double? routeDurationMinutes,
    bool clearError = false,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      recommendations:
          recommendations ?? this.recommendations,
      currentLatitude:
          currentLatitude ?? this.currentLatitude,
      currentLongitude:
          currentLongitude ?? this.currentLongitude,
      errorMessage:
          clearError
              ? null
              : errorMessage ?? this.errorMessage,
       routePoints:
          routePoints ?? this.routePoints,
      routeDistanceKm:
          routeDistanceKm ??
              this.routeDistanceKm,
      routeDurationMinutes:
          routeDurationMinutes ??
              this.routeDurationMinutes,
    );
  }
}