// import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class ImageProcessor {
  //  yub to rgb
  img.Image convertYUVToRGB(CameraImage camImg) {
    final width = camImg.width;
    final height = camImg.height;

    final yPlane = camImg.planes[0];
    final uPlane = camImg.planes[1];
    final vPlane = camImg.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uRowStride = uPlane.bytesPerRow;
    final vRowStride = vPlane.bytesPerRow;

    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;

    final image = img.Image(
      width: width,
      height: height,
    );

    for (int y = 0; y < height; y++) {
      final yRowStart = y * yRowStride;
      final uvY = y ~/ 2;

      for (int x = 0; x < width; x++) {
        final yIndex = yRowStart + x;

        final uvX = x ~/ 2;

        final uIndex =
            uvY * uRowStride +
            uvX * uPixelStride;

        final vIndex =
            uvY * vRowStride +
            uvX * vPixelStride;

        final yValue = yBytes[yIndex].toDouble();
        final uValue = uBytes[uIndex].toDouble() - 128.0;
        final vValue = vBytes[vIndex].toDouble() - 128.0;

        final r = (yValue + 1.402 * vValue)
            .round()
            .clamp(0, 255);

        final g = (
          yValue -
          0.344136 * uValue -
          0.714136 * vValue
        ).round().clamp(0, 255);

        final b = (yValue + 1.772 * uValue)
            .round()
            .clamp(0, 255);

        image.setPixelRgb(
          x,
          y,
          r,
          g,
          b,
        );
      }
    }

    return image;
  }

  // rsize to 224 224 
  img.Image resizeImage(img.Image image) {
    return img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );
  }

  // RGB -> TENSOR

  List<List<List<List<double>>>> imageToTensor(
    img.Image image,
  ) {
    return [
      List.generate(
        224,
        (y) {
          return List.generate(
            224,
            (x) {
              final pixel = image.getPixel(x, y);

              return [
                pixel.r.toDouble(), // R: 0-255
                pixel.g.toDouble(), // G: 0-255
                pixel.b.toDouble(), // B: 0-255
              ];
            },
          );
        },
      ),
    ];
  }

  // image processing pipeline
  List<List<List<List<double>>>> processFrame(
    CameraImage camImg,
  ) {
    
    final rgbImage = convertYUVToRGB(camImg); // YUV420 -> RGB
    img.copyRotate(rgbImage, angle: -90);  // rotating
    final resizedImage = resizeImage(rgbImage);   //  224x224 resize
    final input = imageToTensor(resizedImage);  // RGB -> [1,224,224,3]
    return input;
  }

//   Uint8List imageToJpeg(img.Image image) {
//   return Uint8List.fromList(
//     img.encodeJpg(
//       image,
//       quality: 90,
//     ),
//   );
// }
// ProcessedImageResult processFrameForDebug(
//   CameraImage cameraImage,
// ) {
//   img.Image rgbImage =
//       convertYUVToRGB(cameraImage);

//   // --------------------------------------------------
//   // ROTATION
//   // --------------------------------------------------

//   rgbImage = img.copyRotate(
//     rgbImage,
//     angle: -90,
//   );

//   // --------------------------------------------------
//   // RESIZE
//   // --------------------------------------------------

//   final resizedImage = img.copyResize(
//     rgbImage,
//     width: 224,
//     height: 224,
//     interpolation: img.Interpolation.linear,
//   );

//   // --------------------------------------------------
//   // TENSOR
//   // --------------------------------------------------

//   final tensor = imageToTensor(
//     resizedImage,
//   );

//   // --------------------------------------------------
//   // DEBUG IMAGE
//   // --------------------------------------------------

//   final debugImage =
//       imageToJpeg(resizedImage);

//   return ProcessedImageResult(
//     tensor: tensor,
//     debugImage: debugImage,
//   );
// }
// }
// class ProcessedImageResult {
//   final List<List<List<List<double>>>> tensor;
//   final Uint8List debugImage;

//   const ProcessedImageResult({
//     required this.tensor,
//     required this.debugImage,
//   });
}