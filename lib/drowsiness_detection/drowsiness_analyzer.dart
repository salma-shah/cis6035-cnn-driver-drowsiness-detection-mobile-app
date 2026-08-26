import 'dart:developer';

import 'package:sleepy_driver/drowsiness_detection/calculate_severity.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class DrowsinessAnalysisResult {
  final bool isDrowsy;
  final FatigueSeverity severity;
  final bool cnnDrowsy;
  final bool eyesClosed;
  final bool yawning;
  final Duration eyeClosureDuration;
  final Duration mouthOpenDuration;
  final Duration drowsinessDuration;

  const DrowsinessAnalysisResult({
    required this.isDrowsy,
    required this.severity,
    required this.cnnDrowsy,
    required this.eyesClosed,
    required this.yawning,
    required this.eyeClosureDuration,
    required this.mouthOpenDuration,
    required this.drowsinessDuration,
  });
}

class DrowsinessAnalyzer {
  // cnn
  final double cnnThreshold;
  // ear and mar values
  double earThreshold;
  double marThreshold;

  // thresholds time
  final Duration requiredEyeClosureDuration;
  final Duration requiredYawningDuration;
  // combined drowsiness evidence must remain present
  // for this long before final drowsiness is declared
  final Duration requiredDrowsinessDuration;

  // times
  DateTime? eyeClosureStart;
  DateTime? mouthOpenStart;
  DateTime? drowsinessStart;
  DateTime? lastTimestamp;

  DrowsinessAnalyzer({
    this.cnnThreshold = 0.5,
    required this.earThreshold,
    required this.marThreshold,
    this.requiredEyeClosureDuration = const Duration(seconds: 3),
    this.requiredYawningDuration = const Duration(seconds: 5),
    this.requiredDrowsinessDuration = const Duration(seconds: 3),
  });


  void updateThresholds({
    required double earThreshold,
    required double marThreshold,
  }) {
    this.earThreshold = earThreshold;
    this.marThreshold = marThreshold;
    reset();
  }


  DrowsinessAnalysisResult analyze({
    required double cnnProbability,
    double? ear,
    double? mar,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();

    if (lastTimestamp != null &&
        now.isBefore(lastTimestamp!)) {
      log('Resetting temporal state.',);
      reset();
    }
    lastTimestamp = now;

    final cnnDrowsy = cnnProbability >= cnnThreshold;
    final eyesCurrentlyClosed =
        ear != null &&
        ear.isFinite &&
        ear > 0 &&
        ear < earThreshold;
    final mouthCurrentlyOpen =
        mar != null &&
        mar.isFinite &&
        mar >= 0 &&
        mar > marThreshold;

    if (eyesCurrentlyClosed) {
      eyeClosureStart ??= now;
    } else {
      eyeClosureStart = null;
    }

    final eyeClosureDuration =
        durationSince(
      eyeClosureStart,
      now,
    );

    final sustainedEyeClosure =
        eyeClosureDuration >=
        requiredEyeClosureDuration;

    // track mouth opening duration
    if (mouthCurrentlyOpen) {
      mouthOpenStart ??= now;
    } else {
      mouthOpenStart = null;
    }

    final mouthOpenDuration =
        durationSince(
      mouthOpenStart,
      now,
    );
    final sustainedMouthOpening =
        mouthOpenDuration >=
        requiredYawningDuration;

    // yawning
    final yawning =
        sustainedMouthOpening;

    // combined drowsiness evidence
    final drowsinessEvidence =
        cnnDrowsy && (sustainedEyeClosure || yawning);

    // track combined drowsiness duration
    if (drowsinessEvidence) {
      drowsinessStart ??= now;
    } else {
      drowsinessStart = null;
    }

    final drowsinessDuration =
        durationSince(
      drowsinessStart,
      now,
    );

    // final decision
    final isDrowsy =
        drowsinessDuration >=
        requiredDrowsinessDuration;

    // calculating severity
    final severity = calculateSeverity(
      cnnProbability: cnnProbability,
      eyesClosed: sustainedEyeClosure,
      yawning: yawning,
      eyeClosureDuration: eyeClosureDuration,
      drowsinessDuration: drowsinessDuration,
      isDrowsy: isDrowsy,
    );

    log(
      'CNN: ${cnnProbability.toStringAsFixed(3)} '
      '| CNN Drowsy: $cnnDrowsy '
      '| EAR: ${ear?.toStringAsFixed(3)} '
      '| Eye closed: $sustainedEyeClosure '
      '| Eye duration: ${eyeClosureDuration.inMilliseconds}ms '
      '| MAR: ${mar?.toStringAsFixed(3)} '
      '| Yawning: $yawning '
      '| Drowsy duration: '
      '${drowsinessDuration.inMilliseconds}ms '
      '| Severity: $severity'
      '| FINAL: ${isDrowsy ? "DROWSY" : "NON-DROWSY"}',
    );

    return DrowsinessAnalysisResult(
      isDrowsy: isDrowsy,
      cnnDrowsy: cnnDrowsy,
      eyesClosed: sustainedEyeClosure,
      yawning: yawning,
      eyeClosureDuration: eyeClosureDuration,
      mouthOpenDuration: mouthOpenDuration,
      drowsinessDuration: drowsinessDuration,
      severity: severity
    );
  }

  // duration calculator
  Duration durationSince(
    DateTime? start,
    DateTime now,
  ) {
    if (start == null) {
      return Duration.zero;
    }

    final duration = now.difference(start);
    if (duration.isNegative) {
      return Duration.zero;
    }
    return duration;
  }

  // reset all values
  void reset() {
    eyeClosureStart = null;
    mouthOpenStart = null;
    drowsinessStart = null;
    lastTimestamp = null;
  }
}