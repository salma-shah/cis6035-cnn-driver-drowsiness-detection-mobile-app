part of 'recommendations_bloc.dart';

abstract class RecommendationEvent {
  const RecommendationEvent();
}

class LoadRecommendationsEvent
    extends RecommendationEvent {
  final FatigueSeverity severity;

  const LoadRecommendationsEvent({
    required this.severity,
  });
}

class ClearRecommendationsEvent
    extends RecommendationEvent {
  const ClearRecommendationsEvent();
}

class LoadRouteToRecommendedStopEvent
    extends RecommendationEvent {
  const LoadRouteToRecommendedStopEvent();
}