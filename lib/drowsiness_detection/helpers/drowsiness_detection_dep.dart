import 'package:sleepy_driver/dashboard/services/camera_service.dart';
import 'package:sleepy_driver/drowsiness_detection/repos/drowsiness_detection_repo.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/frame_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/image_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/services/drowsiness_detection_service.dart';
import 'package:sleepy_driver/drowsiness_detection/services/tflite.dart';

DrowsinessDetectionRepo createDrowsinessRepository() {
  final cameraService = CameraService();

  final frameProcessor = FrameProcessor();

  final imageProcessor = ImageProcessor();

  final tfliteService = TfliteService();

  final detector = DrowsinessDetector(
    imageProcessor: imageProcessor,
    tfliteService: tfliteService,
  );

  return DrowsinessDetectionRepo(
    cameraService: cameraService,
    frameProcessor: frameProcessor,
    detector: detector,
  );
}