import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class DrowsinessResult {
  final double probability;
  final double? ear;
  final double? mar;

  final bool isDrowsy;
  final String label;

  final FatigueSeverity severity;

  const DrowsinessResult({
    required this.probability,
    required this.ear,
    required this.mar,
    required this.isDrowsy,
    required this.label,
    required this.severity,
  });
}