import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:sleepy_driver/dashboard/services/camera_service.dart';
import 'package:sleepy_driver/drowsiness_detection/drowsiness_analyzer.dart';
import 'package:sleepy_driver/drowsiness_detection/drowsiness_calibiration.dart';
import 'package:sleepy_driver/drowsiness_detection/models/drowsiness_result.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/face_metrics_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/frame_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/image_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/services/model_detection_service.dart';
import 'package:sleepy_driver/drowsiness_detection/services/face_landmark_analysis_service.dart';

class DrowsinessDetectionRepo {

  final CameraService cameraService;
  final FrameProcessor frameProcessor;
  final ImageProcessor imageProcessor;
  final ModelDetectionService detector;
  final FaceLandmarkService faceLandmarkService;
  final DrowsinessAnalyzer analyzer;
  final FaceMetricsProcessor faceMetricsProcessor;
  final DrowsinessCalibrator drowsinessCalibrator;

  bool isProcessing = false;
  bool isMonitoring = false;

  DrowsinessDetectionRepo({
    required this.cameraService,
    required this.frameProcessor,
    required this.imageProcessor,
    required this.detector,
    required this.faceLandmarkService,
    required this.faceMetricsProcessor,
    required this.analyzer,
    required this.drowsinessCalibrator
  });

  Future<void> initialize() async {
    await cameraService.initialize();
    await detector.initialize();
    await faceLandmarkService.initialize();
    frameProcessor.reset();
    log(
      'Repository: Drowsiness detection initialized.',
    );
  }


  CameraController? get cameraController {return cameraService.controller;}

  bool get isCameraInitialized {return cameraService.isInitialized;}

  bool get isItMonitoring {return isMonitoring;}

  bool get isItProcessing {return isProcessing;}
  bool get isCalibrating => drowsinessCalibrator.isCalibrating;
  
  Future<void> startMonitoring({
    required void Function(DrowsinessResult result)
        onPrediction,
    void Function(Object error)? onError,
  }) async {

    // already running 
    if (isMonitoring) {
      log(
        'Repository: Monitoring is already running.',
      );

      return;
    }

    // camera and facial analysis must be initialized
    if (!cameraService.isInitialized) {
      throw Exception(
        'Camera must be initialized before starting monitoring.');
    }
    if (!faceLandmarkService.isInitialized) {
      throw Exception('Face landmark service is not initialized.');
    }

    isMonitoring = true;
    isProcessing = false;
    frameProcessor.reset();

    drowsinessCalibrator.start();
    log('Repository: Starting calibiration...');
    log('Repository: Starting drowsiness monitoring...',);

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
    } catch (e, stackTrace) {
      isMonitoring = false;

      log('Repository: Failed to start monitoring: $e', stackTrace: stackTrace);

      rethrow;
    }
  }


  void _handleFrame(CameraImage cameraImage, 
  {
    required void Function(DrowsinessResult result) onPrediction,
    void Function(Object error)? onError,
  }) {
    if (!isMonitoring) {
      return;
    }
    if (!frameProcessor.shouldProcessFrame())
    {
      return;
    }
    // don't process another frame while
    // the previous frame is still running
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
  required void Function(DrowsinessResult result)
      onPrediction,
  void Function(Object error)? onError,
}) async {
  try {
    // cnn
    final probability =
        await detector.detect(cameraImage);

    if (!isMonitoring) {
      return;
    }

    log(
      'CNN probability: '
      '${probability.toStringAsFixed(4)}',
    );

    // mediapipe
    final faceResult = await faceLandmarkService.detect(cameraImage);
    if (!isMonitoring) {
      return;
    }
    double? ear;
    double? mar;
    double? headPitch;

    if (faceResult != null &&
        faceResult.hasFace) {
      final metrics =
          faceMetricsProcessor.calculate(
        faceResult,
      );
      if (metrics != null) {
        ear = metrics.ear;
        mar = metrics.mar;
        headPitch = metrics.headPitch;

        log(
          'EAR: '
          '${ear.toStringAsFixed(4)}',
        );

        log(
          'MAR: '
          '${mar.toStringAsFixed(4)}',
        );

        log(
          'Head Pitch: '
          '${headPitch.toStringAsFixed(4)}',
        );
      }
    }
     // calibration
    if (isCalibrating) {
      if (ear != null &&
          mar != null && ear > 0.15 && mar < 0.60) {
        drowsinessCalibrator.addSample(
          ear: ear,
          mar: mar,
        );

        log(
          'Calibration sample: '
          '${drowsinessCalibrator.sampleCount}',
        );
      }

      if (drowsinessCalibrator.hasEnoughSamples) {
        finishCalibration();
      }

      //calibration wont happen during analysis and vice versa
      return;
    }

    // analysis
    final analysis =
        analyzer.analyze(
      cnnProbability: probability,
      ear: ear,
      mar: mar,
      headPitch: headPitch,
      timestamp: DateTime.now()
    );
//     final processed =
//     imageProcessor.processFrameForDebug(
//   cameraImage,
// );

    log(
      'CNN drowsy: '
      '${analysis.cnnDrowsy}',
    );

    log(
      'Eyes closed: '
      '${analysis.eyesClosed}',
    );

    log(
      'Yawning: '
      '${analysis.yawning}',
    );


    log(
      'FINAL: '
      '${analysis.isDrowsy ? "DROWSY" : "NON-DROWSY"}',
    );

    final result =
        DrowsinessResult(
      probability: probability,
      ear: ear,
      mar: mar,
      isDrowsy: analysis.isDrowsy,
      label: analysis.isDrowsy
              ? 'Drowsy'
              : 'Non Drowsy',
      severity: analysis.severity,
      drowsinessDuration: analysis.drowsinessDuration,
    // debugImage: processed.debugImage
    );
    onPrediction(result);

  } catch (e, stackTrace) {
    log(
      'Repository: Drowsiness inference error: $e',
      stackTrace: stackTrace,
    );

    onError?.call(e);

  } finally {
    isProcessing = false;
  }
}

bool finishCalibration() {
  final calibration =
      drowsinessCalibrator.finish();

  if (calibration == null) {
    return false;
  }

  analyzer.updateThresholds(
    earThreshold:
        calibration.earThreshold,
    marThreshold:
        calibration.marThreshold,
  );

  log(
    'Calibration complete.',
  );

  log(
    'EAR baseline: '
    '${calibration.earBaseline}',
  );

  log(
    'EAR threshold: '
    '${calibration.earThreshold}',
  );

  log(
    'MAR baseline: '
    '${calibration.marBaseline}',
  );

  log(
    'MAR threshold: '
    '${calibration.marThreshold}',
  );

  return true;
}

  Future<void> stopMonitoring() async {
    if (!isMonitoring) {
      return;
    }

    log(
      'Repository: Stopping drowsiness monitoring...',
    );

    isMonitoring = false;

    await cameraService.stopStream();

    frameProcessor.reset();
    analyzer.reset();
    isProcessing = false;

    log(
      'Repository: Drowsiness monitoring stopped.',
    );
  }


  Future<void> dispose() async {
    isMonitoring = false;
    isProcessing = false;
    await cameraService.stopStream();
    detector.dispose();
    await faceLandmarkService.dispose();
    await cameraService.dispose();
    analyzer.reset();
    frameProcessor.reset();
  }
}