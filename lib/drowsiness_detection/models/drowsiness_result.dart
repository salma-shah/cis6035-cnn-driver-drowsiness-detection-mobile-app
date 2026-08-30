// import 'dart:typed_data';

import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class DrowsinessResult {
  final double probability;
  final double? ear;
  final double? mar;
  final Duration drowsinessDuration;
  final bool isDrowsy;
  final String label;

  final FatigueSeverity severity;

// final Uint8List? debugImage;

  const DrowsinessResult({
    required this.probability,
    required this.ear,
    required this.mar,
    required this.drowsinessDuration,
    required this.isDrowsy,
    required this.label,
    required this.severity,
 //  required this.debugImage
  });

}