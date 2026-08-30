import 'dart:math' as math;
import 'package:kwon_mediapipe_landmarker/kwon_mediapipe_landmarker.dart';
import 'package:sleepy_driver/drowsiness_detection/models/face_metrics.dart';

class FaceMetricsProcessor {
  FaceMetrics? calculate(
    LandmarkerResult result,
  ) {
    if (!result.hasFace) {
      return null;
    }

    final landmarks =
        result.face!.landmarks;

    final leftEar =
        calculateEyeAspectRatio(
      landmarks,
      upper: [
        159,
        160,
      ],
      lower: [
        145,
        144,
      ],
      left: 33,
      right: 133,
    );

    final rightEar =
        calculateEyeAspectRatio(
      landmarks,
      upper: [
        386,
        385,
      ],
      lower: [
        374,
        380,
      ],
      left: 362,
      right: 263,
    );

    final ear =
        (leftEar + rightEar) / 2;

    final mar =
        calculateMouthAspectRatio(
      landmarks,
    );

    final headPitch =
        calculateHeadPitch(
      landmarks,
    );

    return FaceMetrics(
      ear: ear,
      mar: mar,
      headPitch: headPitch,
    );
  }

  double calculateEyeAspectRatio(
    List<Landmark> landmarks, {
    required List<int> upper,
    required List<int> lower,
    required int left,
    required int right,
  }) {
    final horizontal = _distance(
      landmarks[left],
      landmarks[right],
    );

    final vertical1 = _distance(
      landmarks[upper[0]],
      landmarks[lower[0]],
    );

    final vertical2 = _distance(
      landmarks[upper[1]],
      landmarks[lower[1]],
    );

    if (horizontal == 0) {
      return 0;
    }

    return (vertical1 + vertical2) /
        (2 * horizontal);
  }

  double calculateMouthAspectRatio(
    List<Landmark> landmarks,
  ) {
    final left =
        landmarks[61];

    final right =
        landmarks[291];

    final upper =
        landmarks[13];

    final lower =
        landmarks[14];

    final horizontal =
        _distance(left, right);

    final vertical =
        _distance(upper, lower);

    if (horizontal == 0) {
      return 0;
    }

    return vertical / horizontal;
  }

  // head pitch
 double calculateHeadPitch(
  List<Landmark> landmarks,
) {
  final leftEye =
      landmarks[33];

  final rightEye =
      landmarks[263];

  final nose =
      landmarks[1];

  final eyeY =
      (leftEye.y + rightEye.y) / 2;

  final eyeZ =
      (leftEye.z + rightEye.z) / 2;

  final dy =
      nose.y - eyeY;

  final dz =
      nose.z - eyeZ;

  return math.atan2(
        dy,
        dz,
      ) *
      180 /
      math.pi;
}

  double _distance(
    Landmark a,
    Landmark b,
  ) {
    final dx =
        a.x - b.x;

    final dy =
        a.y - b.y;

    final dz =
        a.z - b.z;

    return math.sqrt(
      dx * dx +
          dy * dy +
          dz * dz,
    );
  }
}