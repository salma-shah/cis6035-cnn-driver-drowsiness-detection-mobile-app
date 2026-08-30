import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

FatigueSeverity calculateSeverity({
  required double cnnProbability,
  required bool eyesClosed,
  required bool yawning,
  required bool headNodding,
  required int recentHeadNodCount,
  required Duration eyeClosureDuration,
  required Duration drowsinessDuration,
  required bool isDrowsy,
}) {

  if (!isDrowsy) {
    return FatigueSeverity.normal;
  }

  // considered severe if  high CNN confidence + prolonged eye closure / mouth closure
  // and head nodding
  if (
    (
      cnnProbability >= 0.85 &&
      eyeClosureDuration >=
          const Duration(seconds: 5)
    ) ||
    drowsinessDuration >=
        const Duration(seconds: 5) ||
    (
      cnnProbability >= 0.85 &&
      recentHeadNodCount >= 3
    )
  ) {
    return FatigueSeverity.severe;
  }

  // moderate is little lesser
  if (
    cnnProbability >= 0.7 ||
    eyeClosureDuration >=
        const Duration(seconds: 2) ||
    drowsinessDuration >=
        const Duration(seconds: 3) ||
    recentHeadNodCount >= 2
  ) {
    return FatigueSeverity.moderate;
  }

  // mild
  return FatigueSeverity.mild;
}