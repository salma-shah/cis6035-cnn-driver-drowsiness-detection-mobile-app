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
  final bool alarmActive;
  final String? errorMessage;
  final CameraController? cameraController;
//   final Uint8List? debugProcessedImage;

  const DrowsinessState({
    this.status = DrowsinessStatus.initial,
    this.probability = 0.0,
    this.ear, this.mar,
    this.isDrowsy = false,
    this.label = 'Unknown',
    this.severity,
    this.alarmActive = false,
    this.errorMessage,
    this.cameraController,
   // this.debugProcessedImage
  });

  DrowsinessState copyWith({
    DrowsinessStatus? status,
    double? probability,
    double? ear,
    double? mar,
    bool? isDrowsy,
    String? label,
    FatigueSeverity? severity,
    bool? alarmActive,
    String? errorMessage,
    CameraController? cameraController,
    bool clearError = false,
    bool clearCameraController = false,
   //  Uint8List? debugProcessedImage,
  //  bool clearDebugImage = false,
  }) {
   return DrowsinessState(
  status: status ?? this.status,
  probability: probability ?? this.probability,

  ear: ear ?? this.ear,
  mar: mar ?? this.mar,

  isDrowsy: isDrowsy ?? this.isDrowsy,
  label: label ?? this.label,
  severity: severity ?? this.severity,
  alarmActive: alarmActive ?? this.alarmActive,

  errorMessage: clearError
      ? null
      : errorMessage ?? this.errorMessage,

  cameraController: clearCameraController
      ? null
      : cameraController ?? this.cameraController,
      //  debugProcessedImage:
      //     clearDebugImage
      //         ? null : debugProcessedImage ?? this.debugProcessedImage,
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