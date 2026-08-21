// import 'package:camera/camera.dart';
// import 'package:image/image.dart' as img;

// class ImageProcessor {
//   // converting to rgb
//   img.Image convertYUVToRGB(CameraImage camImg) {
//     final width = camImg.width;
//     final height = camImg.height;

//     final yPlane = camImg.planes[0];
//     final uPlane = camImg.planes[1];
//     final vPlane = camImg.planes[2];

//     final yBytes = yPlane.bytes;
//     final uBytes = uPlane.bytes;
//     final vBytes = vPlane.bytes;

//     final yRowStride = yPlane.bytesPerRow;
//     final uRowStride = uPlane.bytesPerRow;
//     final vRowStride = vPlane.bytesPerRow;

//     final uPixelStride = uPlane.bytesPerPixel ?? 1;
//     final vPixelStride = vPlane.bytesPerPixel ?? 1;

//     final image = img.Image(
//       width: width,
//       height: height,
//     );

//     for (int y = 0; y < height; y++) {
//       for (int x = 0; x < width; x++) {
//         final yIndex = y * yRowStride + x;

//         final uvX = x ~/ 2;
//         final uvY = y ~/ 2;

//         final uIndex =
//             uvY * uRowStride +
//             uvX * uPixelStride;

//         final vIndex =
//             uvY * vRowStride +
//             uvX * vPixelStride;

//         final yValue = yBytes[yIndex];
//         final uValue = uBytes[uIndex];
//         final vValue = vBytes[vIndex];

//         // YUV -> RGB
//         final r = (
//           yValue + 1.402 * (vValue - 128)
//         ).round().clamp(0, 255);

//         final g = (
//           yValue -
//           0.344136 * (uValue - 128) -
//           0.714136 * (vValue - 128)
//         ).round().clamp(0, 255);

//         final b = (
//           yValue + 1.772 * (uValue - 128)
//         ).round().clamp(0, 255);

//         image.setPixelRgb(
//           x,
//           y,
//           r,
//           g,
//           b,
//         );
//       }
//     }

//     return image;
//   }

//   /// resize images to 224 224
//   img.Image resizeImage(img.Image image) {
//     return img.copyResize(
//       image,
//       width: 224,
//       height: 224,
//       interpolation: img.Interpolation.linear,
//     );
//   }

//   List<List<List<List<double>>>> imageToTensor(
//     img.Image image,
//   ) {
//     return [
//       List.generate(
//         224,
//         (y) => List.generate(
//           224,
//           (x) {
//             final pixel = image.getPixel(x, y);

//             return [
//               pixel.r.toDouble(),
//               pixel.g.toDouble(),
//               pixel.b.toDouble(),
//             ];
//           },
//         ),
//       ),
//     ];
//   }

// // do all processing
//   List<List<List<List<double>>>> processFrame(
//     CameraImage camImg,
//   ) {
//     final rgbImage = convertYUVToRGB(camImg);
//     final resizedImage = resizeImage(rgbImage);
//     final input = imageToTensor(resizedImage);

//     return input;
//   }
// }

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

  // ============================================================
  // 2. DIRECT RESIZE TO 224x224
  // ============================================================
  //
  // IMPORTANT:
  // Your training resized directly to 224x224.
  //
  // Therefore:
  // - NO crop
  // - NO padding
  // - NO letterbox
  // - NO aspect-ratio preservation
  //
  // The camera image is directly resized to 224x224.
  //
  // This may stretch the image if the source is not square,
  // but that is exactly what we want if training did the same.
  // ============================================================

  img.Image resizeImage(img.Image image) {
    return img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );
  }

  // ============================================================
  // 3. RGB IMAGE -> TENSOR
  // ============================================================
  //
  // MobileNetV3Small was created with:
  //
  // include_preprocessing = true
  // The model itself performs its preprocessing.
  //
  // Flutter sends RGB values in the 0-255 range.
  //
  // Output shape:
  //
  // [1, 224, 224, 3]
  //
  // ============================================================

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
    final resizedImage = resizeImage(rgbImage);   //  224x224 resize
    final input = imageToTensor(resizedImage);  // RGB -> [1,224,224,3]
    return input;
  }
}