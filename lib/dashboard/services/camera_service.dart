import 'package:camera/camera.dart';

class CameraService{
  CameraController? cameraController ;
  CameraController? get controller => cameraController;
  bool get isInitialized => cameraController != null && cameraController!.value.isInitialized;

 // checking if camera has access
  Future<void> initialize() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw Exception("No cameras available");
    }

    // using front camera
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    cameraController = CameraController(
      frontCamera,
      ResolutionPreset.low,
      enableAudio: false,
    );

    await cameraController!.initialize();
  }


  Future<void> dispose() async {
    await cameraController?.dispose();
    cameraController = null;
  }

  // starting stream
  Future<void> startCaptureStream(Function (CameraImage camImg) onFrame) async {
    if (!isInitialized)
    {throw Exception("Camera is not initialized");}
    
    if (cameraController!.value.isStreamingImages) {
    return;
  }
  await cameraController!.startImageStream(onFrame);
  }

  Future<void> stopStream() async {
  if (cameraController?.value.isStreamingImages == true) {
    await cameraController!.stopImageStream();
  }
}
}