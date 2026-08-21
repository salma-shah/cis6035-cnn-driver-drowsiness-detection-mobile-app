import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:kwon_mediapipe_landmarker/kwon_mediapipe_landmarker.dart';

class FaceLandmarkService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await KwonMediapipeLandmarker.initialize(
      face: true,
      pose: false,
      faceOptions: const FaceOptions(
        numFaces: 1,
        minDetectionConfidence: 0.5,
        minTrackingConfidence: 0.5,
        outputBlendshapes: false,
        outputTransformationMatrix: false,
      ),
    );

    _isInitialized = true;

    log('MediaPipe Face Landmarker initialized.');
  }

  Future<LandmarkerResult?> detect(
    CameraImage image,
  ) async {
    if (!_isInitialized) {
      throw Exception(
        'FaceLandmarkService has not been initialized.',
      );
    }

    try {
      final result =
          await KwonMediapipeLandmarker.detectFromCamera(
        planes: image.planes
            .map((plane) => plane.bytes)
            .toList(),
        width: image.width,
        height: image.height,
        rotation: 0,
        format: 'YUV420',
        bytesPerRow: image.planes
            .map((plane) => plane.bytesPerRow)
            .toList(),
      );

      return result;
    } catch (e, stackTrace) {
      log(
        'MediaPipe detection error: $e',
        stackTrace: stackTrace,
      );

      return null;
    }
  }

  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    KwonMediapipeLandmarker.dispose();

    _isInitialized = false;

    log('MediaPipe Face Landmarker disposed.');
  }
}