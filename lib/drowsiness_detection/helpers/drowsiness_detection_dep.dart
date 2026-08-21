import 'package:sleepy_driver/dashboard/services/camera_service.dart';
import 'package:sleepy_driver/drowsiness_detection/drowsiness_analyzer.dart';
import 'package:sleepy_driver/drowsiness_detection/drowsiness_calibiration.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/face_metrics_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/repos/drowsiness_detection_repo.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/frame_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/image_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/services/model_detection_service.dart';
import 'package:sleepy_driver/drowsiness_detection/services/face_landmark_analysis_service.dart';
import 'package:sleepy_driver/drowsiness_detection/services/tflite.dart';

DrowsinessDetectionRepo createDrowsinessRepository() {
  final cameraService = CameraService();
  final frameProcessor = FrameProcessor();
  final imageProcessor = ImageProcessor();
  final tfliteService = TfliteService();
  final faceLandmarkAnalysis = FaceLandmarkService();
  final faceMetricsProcessor = FaceMetricsProcessor();
  final drowsinessAnalyzer = DrowsinessAnalyzer( earThreshold: 0.20, marThreshold: 0.60,);
  final drowsinessCalibrator = DrowsinessCalibrator();

  final detector = ModelDetectionService(
    imageProcessor: imageProcessor,
    tfliteService: tfliteService,
  );

  return DrowsinessDetectionRepo(
    cameraService: cameraService,
    frameProcessor: frameProcessor,
    detector: detector,
    faceLandmarkService: faceLandmarkAnalysis,
    faceMetricsProcessor: faceMetricsProcessor,
    analyzer: drowsinessAnalyzer,
    drowsinessCalibrator: drowsinessCalibrator
    
  );
}