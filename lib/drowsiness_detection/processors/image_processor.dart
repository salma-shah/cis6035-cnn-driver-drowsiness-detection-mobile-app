import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class ImageProcessor {
  // converting to rgb
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
      for (int x = 0; x < width; x++) {
        final yIndex = y * yRowStride + x;

        final uvX = x ~/ 2;
        final uvY = y ~/ 2;

        final uIndex =
            uvY * uRowStride +
            uvX * uPixelStride;

        final vIndex =
            uvY * vRowStride +
            uvX * vPixelStride;

        final yValue = yBytes[yIndex];
        final uValue = uBytes[uIndex];
        final vValue = vBytes[vIndex];

        // YUV -> RGB
        final r = (
          yValue + 1.402 * (vValue - 128)
        ).round().clamp(0, 255);

        final g = (
          yValue -
          0.344136 * (uValue - 128) -
          0.714136 * (vValue - 128)
        ).round().clamp(0, 255);

        final b = (
          yValue + 1.772 * (uValue - 128)
        ).round().clamp(0, 255);

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

  /// resize images to 224 224
  img.Image resizeImage(img.Image image) {
    return img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );
  }

  List<List<List<List<double>>>> imageToTensor(
    img.Image image,
  ) {
    return [
      List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = image.getPixel(x, y);

            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    ];
  }

// do all processing
  List<List<List<List<double>>>> processFrame(
    CameraImage camImg,
  ) {
    final rgbImage = convertYUVToRGB(camImg);
    final resizedImage = resizeImage(rgbImage);
    final input = imageToTensor(resizedImage);

    return input;
  }
}