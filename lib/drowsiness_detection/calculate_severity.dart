import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

FatigueSeverity calculateSeverity ({
    required double cnnProbability,
    required bool eyesClosed,
    required bool yawning,
    required Duration eyeClosureDuration,
    required Duration drowsinessDuration,
    required bool isDrowsy,
  }) {

    // if not drowsy then normal active level
     if (!isDrowsy) {
      return FatigueSeverity.normal;
    }

    // severe is
    //very high CNN confidence + prolonged eye closure
    // OR prolonged overall drowsiness

    if (
        (cnnProbability >= 0.85 &&
            eyeClosureDuration >=
                const Duration(seconds: 5)) ||
        drowsinessDuration >=
            const Duration(seconds: 5)) {
      return FatigueSeverity.severe;
    }

    // moderate
    // sustained drowsiness with strong evidence

    if (
        cnnProbability >= 0.7 ||
        eyeClosureDuration >=
            const Duration(seconds: 2) ||
        drowsinessDuration >=
            const Duration(seconds: 3)) {
      return FatigueSeverity.moderate;
    }

    // otherwise it is mild
    return FatigueSeverity.mild;

  }