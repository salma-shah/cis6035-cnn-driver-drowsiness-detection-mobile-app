import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/suggestions/repos/rec_repo.dart';
import 'package:sleepy_driver/suggestions/viewmodels/bloc/recommendations_state.dart';

part 'recommendations_event.dart';

class RecommendationBloc extends Bloc<RecommendationEvent,RecommendationState> {
  RecommendationRepo repository;

  RecommendationBloc({
    required this.repository,
  }) : super(
          const RecommendationState(),
        ) {
    on<LoadRecommendationsEvent>(
      loadRecommendations,
    );

    on<ClearRecommendationsEvent>(
      clearRecommendations,
    );

    on<LoadRouteToRecommendedStopEvent>(
  loadRouteToRecommendedStop,
);

  }
Future<void> loadRecommendations(
  LoadRecommendationsEvent event,
  Emitter<RecommendationState> emit,
) async {
  try {
    emit(
      state.copyWith(
        status: RecommendationStatus.loading,
        clearError: true,
      ),
    );

    final data =
        await repository.getRecommendations(
      severity: event.severity,
    );

    if (data.stops.isEmpty) {
      emit(
        state.copyWith(
          status: RecommendationStatus.empty,
          recommendations: const [],
          currentLatitude:
              data.currentLocation.latitude,
          currentLongitude:
              data.currentLocation.longitude,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        status: RecommendationStatus.loaded,
        recommendations: data.stops,
        currentLatitude:
            data.currentLocation.latitude,
        currentLongitude:
            data.currentLocation.longitude,
      ),
    );

    add(
  const LoadRouteToRecommendedStopEvent(),
);

  } catch (e, stackTrace) {
    log(
      'Recommendation error: $e',
      stackTrace: stackTrace,
    );

    emit(
      state.copyWith(
        status: RecommendationStatus.error,
        errorMessage: 'Something went wrong. We apologize.',
      ),
    );
  }
}

  void clearRecommendations(
    ClearRecommendationsEvent event,
    Emitter<RecommendationState> emit,
  ) {
    emit(
      const RecommendationState(),
    );
  }

  Future<void> loadRouteToRecommendedStop(
  LoadRouteToRecommendedStopEvent event,
  Emitter<RecommendationState> emit,
) async {
  try {
    if (state.recommendations.isEmpty) {
      return;
    }

    final stop =
        state.recommendations.first;

    final route =
        await repository.getRouteToStop(
      stop,
    );

    emit(
      state.copyWith(
        routePoints: route.points,
        routeDistanceKm:
            route.distanceKm,
        routeDurationMinutes:
            route.durationMinutes,
      ),
    );
  } catch (e, stackTrace) {
    log(
      'Routing error: $e',
      stackTrace: stackTrace,
    );

    emit(
      state.copyWith(
        errorMessage:
            'Unable to calculate route.',
      ),
    );
  }
}
}
