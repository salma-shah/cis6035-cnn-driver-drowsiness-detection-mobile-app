import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:sleepy_driver/dashboard/services/camera_service.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/frame_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/services/drowsiness_detection_service.dart';

class DrowsinessDetectionRepo {
  final CameraService cameraService;
  final FrameProcessor frameProcessor;
  final DrowsinessDetector detector;

  bool isProcessing = false;
  bool isMonitoring = false;

  DrowsinessDetectionRepo({
    required this.cameraService,
    required this.frameProcessor,
    required this.detector,
  });

 Future<void> initialize() async {
  log(
    'Initializing drowsiness detection...',
  );

  await cameraService.initialize();

  await detector.initialize();

  frameProcessor.reset();

  log(
    'Drowsiness detection initialized.',
  );
}


  CameraController? get cameraController {
    return cameraService.controller;
  }

  bool get isCameraInitialized {
    return cameraService.isInitialized;
  }



  bool get isItMonitoring {
    return isMonitoring;
  }

  bool get isItProcessing {
    return isProcessing;
  }


  Future<void> startMonitoring({
    required void Function(double probability) onPrediction,
    void Function(Object error)? onError,
  }) async {
    if (isMonitoring) {
      log(
        'Drowsiness monitoring is already running.',
      );
      return;
    }

    if (!cameraService.isInitialized) {
      throw Exception(
        'Camera must be initialized before starting monitoring.',
      );
    }

    isMonitoring = true;
    isProcessing = false;

    frameProcessor.reset();

    log(
      'Starting drowsiness monitoring...',
    );

    try {
      await cameraService.startCaptureStream(
        (CameraImage cameraImage) {
          _handleFrame(
            cameraImage,
            onPrediction: onPrediction,
            onError: onError,
          );
        },
      );
    } catch (e) {
      isMonitoring = false;

      log(
        'Failed to start drowsiness monitoring: $e',
      );

      rethrow;
    }
  }

  void _handleFrame(
    CameraImage cameraImage, {
    required void Function(double probability) onPrediction,
    void Function(Object error)? onError,
  }) {
    // Monitoring was stopped.
    if (!isMonitoring) {
      return;
    }

    // frameProcessor decides whether this frame
    // should be sent to  CNN
    if (!frameProcessor.runCNNInference()) {
      return;
    }

   // avoiding processing multiple frames when one is still being processed
    if (isProcessing) {
      return;
    }

    isProcessing = true;

    _processFrame(
      cameraImage,
      onPrediction: onPrediction,
      onError: onError,
    );
  }


  Future<void> _processFrame(
    CameraImage cameraImage, {
    required void Function(double probability) onPrediction,
    void Function(Object error)? onError,
  }) async {
    try {
      final probability = await detector.detect(
        cameraImage,
      );

      if (!isMonitoring) {
        return;
      }

      onPrediction(probability);
    } catch (e, stackTrace) {
      log(
        'Drowsiness inference error: $e',
      );

      log(
        'Stack trace: $stackTrace',
      );

      onError?.call(e);
    } finally {
      isProcessing = false;
    }
  }

  // end monitoring

  Future<void> stopMonitoring() async {
    if (!isMonitoring) {
      return;
    }

    log(
      'Stopping drowsiness monitoring...',
    );

    isMonitoring = false;

    await cameraService.stopStream();

    frameProcessor.reset();

    isProcessing = false;

    log(
      'Drowsiness monitoring stopped.',
    );
  }

  Future<void> dispose() async {
    isMonitoring = false;
    isProcessing = false;

    await cameraService.stopStream();

    detector.dispose();

    await cameraService.dispose();

    frameProcessor.reset();

    log(
      'Drowsiness detection repository disposed.',
    );
  }
}