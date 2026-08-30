import 'package:camera/camera.dart';
import 'package:sleepy_driver/drowsiness_detection/processors/image_processor.dart';
import 'package:sleepy_driver/drowsiness_detection/services/tflite.dart';

class DrowsinessDetector {
  final ImageProcessor imageProcessor;
  final TfliteService tfliteService;

  DrowsinessDetector({
    required this.imageProcessor,
    required this.tfliteService,
  });

  Future<void> initialize() async {
    await tfliteService.loadModel();
  }

  Future<double> detect(
    CameraImage cameraImage,
  ) async {
    final input = imageProcessor.processFrame(
      cameraImage,
    );

    final probability = tfliteService.predict(
      input,
    );

    return probability;
  }

  void dispose() {
    tfliteService.dispose();
  }
}