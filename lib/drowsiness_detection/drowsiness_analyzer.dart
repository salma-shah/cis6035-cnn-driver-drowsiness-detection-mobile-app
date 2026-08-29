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
  final double headPitch;
  final bool headNodding;
  final int recentHeadNodCount;

  const DrowsinessAnalysisResult({
    required this.isDrowsy,
    required this.severity,
    required this.cnnDrowsy,
    required this.eyesClosed,
    required this.yawning,
    required this.eyeClosureDuration,
    required this.mouthOpenDuration,
    required this.drowsinessDuration,
    required this.headPitch,
    required this.headNodding,
    required this.recentHeadNodCount,
  });
}

class DrowsinessAnalyzer {
  final double cnnThreshold;
  double earThreshold;
  double marThreshold;
  final Duration requiredEyeClosureDuration;
  final Duration requiredYawningDuration;
  final Duration requiredDrowsinessDuration;
  final double headNodAngleThreshold;
  final Duration headNodDuration;
  final Duration headNodWindow;
  DateTime? eyeClosureStart;
  DateTime? mouthOpenStart;
  DateTime? drowsinessStart;
  DateTime? lastTimestamp;
  double? previousHeadPitch;
  DateTime? headNodDownStart;
  bool nodDownDetected = false;

  /// stores only nods occurred recently
  final List<DateTime> headNodTimestamps = [];

  DrowsinessAnalyzer({
    this.cnnThreshold = 0.5,

    required this.earThreshold,
    required this.marThreshold,

    this.requiredEyeClosureDuration =
        const Duration(seconds: 3),

    this.requiredYawningDuration =
        const Duration(seconds: 5),

    this.requiredDrowsinessDuration =
        const Duration(seconds: 3),

    this.headNodAngleThreshold = 8.0,

    this.headNodDuration =
        const Duration(milliseconds: 1500),

    this.headNodWindow =
        const Duration(seconds: 30),
  });


  void updateThresholds({
    required double earThreshold,
    required double marThreshold,
  }) {
    this.earThreshold = earThreshold;
    this.marThreshold = marThreshold;

    reset();
  }

  // main analysis
  DrowsinessAnalysisResult analyze({
    required double cnnProbability,
    double? ear,
    double? mar,
    double? headPitch,
    DateTime? timestamp,
  }) {
    final now =
        timestamp ?? DateTime.now();

    if (lastTimestamp != null &&
        now.isBefore(lastTimestamp!)) {
      log(
        'Resetting temporal state because timestamp moved backwards.',
      );

      reset();
    }

    lastTimestamp = now;
    _removeExpiredHeadNods(now);


    final cnnDrowsy =
        cnnProbability >= cnnThreshold;

    final eyesCurrentlyClosed =
        ear != null &&
        ear.isFinite &&
        ear > 0 &&
        ear < earThreshold;

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

    final mouthCurrentlyOpen =
        mar != null &&
        mar.isFinite &&
        mar >= 0 &&
        mar > marThreshold;

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

    final yawning =
        sustainedMouthOpening;

    final headNodding = headPitch != null ? detectHeadNodding(headPitch: headPitch,now: now): false;

    _removeExpiredHeadNods(now);
    final recentHeadNodCount =
        headNodTimestamps.length;

    // combining all facial analysis and model probability to create evidence to decide whether drowsy or not
    // final decision
    final drowsinessEvidence =
        cnnDrowsy &&
        (
          sustainedEyeClosure ||
          yawning ||
          headNodding ||
          recentHeadNodCount >= 2
        );


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

    final isDrowsy =
        drowsinessDuration >=
            requiredDrowsinessDuration;
            
    // calculating the severity
    final severity =
        calculateSeverity(
      cnnProbability:cnnProbability,
      eyesClosed: sustainedEyeClosure,
      yawning:  yawning,         
      headNodding:  headNodding,
      recentHeadNodCount:   recentHeadNodCount,    
      eyeClosureDuration:   eyeClosureDuration,
      drowsinessDuration:      drowsinessDuration,
      isDrowsy:    isDrowsy      
    );

    log(
      'CNN: ${cnnProbability.toStringAsFixed(3)} '
      '| CNN Drowsy: $cnnDrowsy '
      '| EAR: ${ear?.toStringAsFixed(3)} '
      '| Eye closed: $sustainedEyeClosure '
      '| Eye duration: ${eyeClosureDuration.inMilliseconds}ms '
      '| MAR: ${mar?.toStringAsFixed(3)} '
      '| Yawning: $yawning '
      '| Head pitch: '
      '${headPitch?.toStringAsFixed(2)} '
      '| Head nod: $headNodding '
      '| Recent nods: $recentHeadNodCount '
      '| Drowsy duration: '
      '${drowsinessDuration.inMilliseconds}ms '
      '| Severity: $severity '
      '| FINAL: '
      '${isDrowsy ? "DROWSY" : "NON-DROWSY"}',
    );


    return DrowsinessAnalysisResult(
      isDrowsy:
          isDrowsy,

      severity:
          severity,

      cnnDrowsy:
          cnnDrowsy,

      eyesClosed:
          sustainedEyeClosure,

      yawning:
          yawning,

      eyeClosureDuration:
          eyeClosureDuration,

      mouthOpenDuration:
          mouthOpenDuration,

      drowsinessDuration:
          drowsinessDuration,

      headPitch:
          headPitch ?? 0.0,

      headNodding:
          headNodding,

      recentHeadNodCount:
          recentHeadNodCount,
    );
  }


  bool detectHeadNodding({
    required double headPitch,
    required DateTime now,
  }) {
    if (previousHeadPitch == null) {
      previousHeadPitch =
          headPitch;

      return false;
    }

    final pitchChange =
        headPitch -
            previousHeadPitch!;

    previousHeadPitch =
        headPitch;

    // ignoring small movements caused by
    // landmark noise
    if (pitchChange.abs() <
        headNodAngleThreshold) {
      return false;
    }


    if (pitchChange >
        headNodAngleThreshold) {
      nodDownDetected = true;

      headNodDownStart ??= now;

      return false;
    }

    if (pitchChange <
        -headNodAngleThreshold) {
      if (nodDownDetected &&
          headNodDownStart != null) {
        final duration =
            now.difference(
          headNodDownStart!,
        );

        // valid complete nod
        if (duration <=
            headNodDuration) {
          headNodTimestamps.add(
            now,
          );

          nodDownDetected = false;
          headNodDownStart = null;

          _removeExpiredHeadNods(now);

          return true;
        }
      }

      // invalid upward movement
      nodDownDetected = false;
      headNodDownStart = null;
    }

    return false;
  }

  void _removeExpiredHeadNods(
    DateTime now,
  ) {
    headNodTimestamps.removeWhere(
      (nodTime) {
        final age =
            now.difference(nodTime);

        return age > headNodWindow;
      },
    );
  }

  Duration durationSince(
    DateTime? start,
    DateTime now,
  ) {
    if (start == null) {
      return Duration.zero;
    }

    final duration =
        now.difference(start);

    if (duration.isNegative) {
      return Duration.zero;
    }

    return duration;
  }

  void reset() {
    eyeClosureStart = null;
    mouthOpenStart = null;
    drowsinessStart = null;
    lastTimestamp = null;

    previousHeadPitch = null;
    headNodDownStart = null;
    nodDownDetected = false;

    headNodTimestamps.clear();
  }
}