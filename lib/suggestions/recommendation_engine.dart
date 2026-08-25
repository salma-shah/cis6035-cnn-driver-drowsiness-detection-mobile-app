import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/suggestions/models/rest_stop.dart';
import 'package:sleepy_driver/suggestions/models/scored_stop.dart';

class RecommendationEngine {
  List<RestStop> recommend({
    required List<RestStop> stops,
    required FatigueSeverity severity,
    int limit = 5,
  }) {
    final scored = stops.map(
      (stop) {
        return ScoredStop(
          stop: stop,
          score: score(
            stop: stop,
            severity: severity,
          ),
        );
      },
    ).toList();

    scored.sort(
      (a, b) =>
          b.score.compareTo(a.score),
    );

    return scored
        .take(limit)
        .map(
          (item) => item.stop,
        )
        .toList();
  }

  double score({
    required RestStop stop,
    required FatigueSeverity severity,
  }) {
    double score = 0;

    // calculating distance

    if (stop.distanceKm <= 1) {
      score += 50;
    } else if (stop.distanceKm <= 2) {
      score += 40;
    } else if (stop.distanceKm <= 5) {
      score += 25;
    } else if (stop.distanceKm <= 10) {
      score += 10;
    }

    // diff rest stop types

    switch (stop.type) {
      case 'rest_area':
      case 'services':
        score += 30;
        break;

      case 'fuel':
        score += 20;
        break;

      case 'cafe':
      case 'restaurant':
        score += 15;
        break;

      case 'fast_food':
        score += 10;
        break;

      case 'parking_space':
        score += 5;
        break;

      default:
        break;
    }

    // based on severity

    if (severity ==
        FatigueSeverity.severe) {
      // for severe fatigue, prioritize close stops
      score +=
          mathSafeDistanceBonus(
        stop.distanceKm,
      );
    }

    return score;
  }

  double mathSafeDistanceBonus(
    double distanceKm,
  ) {
    if (distanceKm <= 1) return 20;
    if (distanceKm <= 2) return 15;
    if (distanceKm <= 5) return 8;
    return 0;
  }
}