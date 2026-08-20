import 'package:camera/camera.dart';

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
  final bool isDrowsy;
  final String label;
  final String? errorMessage;
  final CameraController? cameraController;

  const DrowsinessState({
    this.status = DrowsinessStatus.initial,
    this.probability = 0.0,
    this.isDrowsy = false,
    this.label = 'Unknown',
    this.errorMessage,
    this.cameraController
  });

  DrowsinessState copyWith({
    DrowsinessStatus? status,
    double? probability,
    bool? isDrowsy,
    String? label,
    String? errorMessage,
    CameraController? cameraController,
    bool clearError = false,
    bool clearCameraController = false
  }) {
    return DrowsinessState(
      status: status ?? this.status,
      probability: probability ?? this.probability,
      isDrowsy: isDrowsy ?? this.isDrowsy,
      label: label ?? this.label,
      errorMessage:
          clearError
              ? null
              : errorMessage ?? this.errorMessage,
      cameraController:
          clearCameraController
              ? null
              : cameraController ?? this.cameraController
    );
  }

  List<Object?> get props => [
        status,
        probability,
        isDrowsy,
        label,
        errorMessage,
        cameraController
      ];
}