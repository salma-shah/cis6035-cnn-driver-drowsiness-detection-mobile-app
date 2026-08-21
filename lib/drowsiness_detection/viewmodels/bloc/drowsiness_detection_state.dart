import 'package:camera/camera.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

enum DrowsinessStatus {
  initial,
  initializing,
  ready,
  monitoring,
  stopped,
  error,
}

class DrowsinessState {
  final DrowsinessStatus status;
  final double probability;
  final double? ear;
  final double? mar;
  final bool isDrowsy;
  final String label;
  final FatigueSeverity? severity;
  final String? errorMessage;
  final CameraController? cameraController;

  const DrowsinessState({
    this.status = DrowsinessStatus.initial,
    this.probability = 0.0,
    this.ear, this.mar,
    this.isDrowsy = false,
    this.label = 'Unknown',
    this.severity,
    this.errorMessage,
    this.cameraController
  });

  DrowsinessState copyWith({
    DrowsinessStatus? status,
    double? probability,
    double? ear,
    double? mar,
    bool? isDrowsy,
    String? label,
    FatigueSeverity? severity,
    String? errorMessage,
    CameraController? cameraController,
    bool clearError = false,
    bool clearCameraController = false
  }) {
   return DrowsinessState(
  status: status ?? this.status,
  probability: probability ?? this.probability,

  ear: ear ?? this.ear,
  mar: mar ?? this.mar,

  isDrowsy: isDrowsy ?? this.isDrowsy,
  label: label ?? this.label,
  severity: severity ?? this.severity,

  errorMessage: clearError
      ? null
      : errorMessage ?? this.errorMessage,

  cameraController: clearCameraController
      ? null
      : cameraController ?? this.cameraController,
);
  }

  List<Object?> get props => [
        status,
        probability,
        ear, mar,
        isDrowsy,
        label,
        errorMessage,
        cameraController
      ];
}