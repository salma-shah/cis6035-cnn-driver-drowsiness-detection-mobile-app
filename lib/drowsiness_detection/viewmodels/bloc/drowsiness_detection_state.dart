//import 'dart:typed_data';

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
  final bool onBreak;

  // trip info
  final String? tripId;
  final DateTime? tripStartTime;
  final Duration tripDuration;
  final int totalDrowsinessEvents;
  final int totalAlerts;
  final FatigueSeverity maxSeverity;

  //final Uint8List? debugImage;


  const DrowsinessState({
    this.status = DrowsinessStatus.initial,
    this.probability = 0.0,
    this.ear,
    this.mar,
    this.isDrowsy = false,
    this.label = 'Unknown',
    this.severity,
    this.alarmActive = false,
    this.errorMessage,
    this.cameraController,
    this.tripId,
    this.tripStartTime,
    this.tripDuration = Duration.zero,
    this.onBreak = false,
    this.totalDrowsinessEvents = 0,
    this.totalAlerts = 0,
    this.maxSeverity = FatigueSeverity.normal,
   // this.debugImage,

  });

  DrowsinessState copyWith({
    DrowsinessStatus? status,
    CameraController? cameraController,
    double? probability,
    double? ear,
    double? mar,
    bool? isDrowsy,
    String? label,
    FatigueSeverity? severity,
    bool? alarmActive,
    final String? tripId,
    DateTime? tripStartTime,
    Duration? tripDuration,
    bool? onBreak,
    String? errorMessage,

    bool clearError = false,
    bool clearTripStartTime = false,
    bool clearEar = false,
    bool clearMar = false,
    bool clearCameraController = false,

    int? totalDrowsinessEvents,
    int? totalAlerts,
    FatigueSeverity? maxSeverity,

   // Uint8List? debugImage,
  }) {
    return DrowsinessState(
      status: status ?? this.status,

      cameraController: clearCameraController
          ? null
          : cameraController ?? this.cameraController,

      probability: probability ?? this.probability,

      ear: clearEar
          ? null
          : ear ?? this.ear,

      mar: clearMar
          ? null
          : mar ?? this.mar,

      isDrowsy: isDrowsy ?? this.isDrowsy,

      label: label ?? this.label,

      severity: severity ?? this.severity,

      alarmActive: alarmActive ?? this.alarmActive,
      tripId: tripId ?? this.tripId,
      tripStartTime: clearTripStartTime
          ? null
          : tripStartTime ?? this.tripStartTime,

      tripDuration: tripDuration ?? this.tripDuration,

      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,

      totalDrowsinessEvents:
          totalDrowsinessEvents ??
              this.totalDrowsinessEvents,

      totalAlerts:
          totalAlerts ?? this.totalAlerts,

      maxSeverity:
          maxSeverity ?? this.maxSeverity,

      onBreak: onBreak ?? this.onBreak,
      //  debugImage:
      //     debugImage ?? this.debugImage,
    );
  }

  List<Object?> get props => [
        status,
        probability,
        ear,
        mar,
        isDrowsy,
        label,
        severity,
        alarmActive,
        errorMessage,
        cameraController,
        tripStartTime,
        tripDuration,
        totalDrowsinessEvents,
        totalAlerts,
        maxSeverity,
      ];
}