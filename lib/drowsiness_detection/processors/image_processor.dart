import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class ImageProcessor {
  final double lowLightThreshold;

  ImageProcessor({
    this.lowLightThreshold = 70.0,
  });

  img.Image convertYUVToRGB(
    CameraImage camImg,
  ) {
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

    final uPixelStride =
        uPlane.bytesPerPixel ?? 1;

    final vPixelStride =
        vPlane.bytesPerPixel ?? 1;

    final image = img.Image(
      width: width,
      height: height,
    );

    for (int y = 0; y < height; y++) {
      final yRowStart =
          y * yRowStride;

      final uvY =
          y ~/ 2;

      for (int x = 0; x < width; x++) {
        final yIndex =
            yRowStart + x;

        final uvX =
            x ~/ 2;

        final uIndex =
            uvY * uRowStride +
            uvX * uPixelStride;

        final vIndex =
            uvY * vRowStride +
            uvX * vPixelStride;

        final yValue =
            yBytes[yIndex].toDouble();

        final uValue =
            uBytes[uIndex].toDouble() -
                128.0;

        final vValue =
            vBytes[vIndex].toDouble() -
                128.0;

        final r =
            (yValue + 1.402 * vValue)
                .round()
                .clamp(0, 255);

        final g =
            (
              yValue -
              0.344136 * uValue -
              0.714136 * vValue
            )
                .round()
                .clamp(0, 255);

        final b =
            (yValue + 1.772 * uValue)
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

  double calculateAverageBrightness(
    CameraImage cameraImage,
  ) {
    final yPlane =
        cameraImage.planes[0];

    final bytes =
        yPlane.bytes;

    if (bytes.isEmpty) {
      return 0;
    }

    double total = 0;
    int count = 0;

    final step =
        math.max(
      1,
      bytes.length ~/ 1000,
    );

    for (
      int i = 0;
      i < bytes.length;
      i += step
    ) {
      total += bytes[i];
      count++;
    }

    if (count == 0) {
      return 0;
    }

    return total / count;
  }

  bool isLowLight(
    CameraImage cameraImage,
  ) {
    return calculateAverageBrightness(
          cameraImage,
        ) <
        lowLightThreshold;
  }

  img.Image enhanceLowLight(
    img.Image image, {
    double brightness = 1.10,
    double contrast = 1.10,
  }) {
    return img.adjustColor(
      image,
      brightness: brightness,
      contrast: contrast,
    );
  }

  img.Image gammaCorrect(
    img.Image image, {
    double gamma = 1.4,
  }) {
    final result =
        img.Image.from(image);

    for (
      int y = 0;
      y < image.height;
      y++
    ) {
      for (
        int x = 0;
        x < image.width;
        x++
      ) {
        final pixel =
            image.getPixel(x, y);

        final r = _gamma(
          pixel.r.toInt(),
          gamma,
        );

        final g = _gamma(
          pixel.g.toInt(),
          gamma,
        );

        final b = _gamma(
          pixel.b.toInt(),
          gamma,
        );

        result.setPixelRgb(
          x,
          y,
          r,
          g,
          b,
        );
      }
    }

    return result;
  }

  int _gamma(
    int value,
    double gamma,
  ) {
    final normalized =
        value / 255.0;

    final corrected =
        math.pow(
          normalized,
          1.0 / gamma,
        );

    return (corrected * 255)
        .round()
        .clamp(0, 255);
  }

  img.Image resizeImage(
    img.Image image,
  ) {
    return img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation:
          img.Interpolation.linear,
    );
  }

  List<List<List<List<double>>>>
      imageToTensor(
    img.Image image,
  ) {
    return [
      List.generate(
        224,
        (y) {
          return List.generate(
            224,
            (x) {
              final pixel =
                  image.getPixel(
                x,
                y,
              );

              return [
                pixel.r.toDouble(),
                pixel.g.toDouble(),
                pixel.b.toDouble(),
              ];
            },
          );
        },
      ),
    ];
  }

  List<List<List<List<double>>>>
      processFrame(
    CameraImage cameraImage,
  ) {
    final lowLight =
        isLowLight(
      cameraImage,
    );

    final rgbImage =
        convertYUVToRGB(
      cameraImage,
    );

    img.Image processedImage =
        rgbImage;

    if (lowLight) {
      processedImage =
          gammaCorrect(
        processedImage,
        gamma: 1.4,
      );

      processedImage =
          enhanceLowLight(
        processedImage,
        brightness: 1.10,
        contrast: 1.10,
      );
    }

    final resizedImage =
        resizeImage(
      processedImage,
    );

    return imageToTensor(
      resizedImage,
    );
  }

  Uint8List imageToJpeg(
    img.Image image, {
    int quality = 90,
  }) {
    return Uint8List.fromList(
      img.encodeJpg(
        image,
        quality: quality,
      ),
    );
  }

  ProcessedImageResult
      processFrameForDebug(
    CameraImage cameraImage,
  ) {
    final lowLight =
        isLowLight(
      cameraImage,
    );

    final brightness =
        calculateAverageBrightness(
      cameraImage,
    );

    img.Image rgbImage =
        convertYUVToRGB(
      cameraImage,
    );

    final originalImage =
        img.copyRotate(
      rgbImage,
      angle: -90,
    );

    img.Image processedImage =
        originalImage;

    if (lowLight) {
      processedImage =
          gammaCorrect(
        processedImage,
        gamma: 1.4,
      );

      processedImage =
          enhanceLowLight(
        processedImage,
        brightness: 1.10,
        contrast: 1.10,
      );

      processedImage = img.flip(
  processedImage,
  direction: img.FlipDirection.vertical,
);
    }

    final resizedImage =
        img.copyResize(
      processedImage,
      width: 224,
      height: 224,
      interpolation:
          img.Interpolation.linear,
    );

    final tensor =
        imageToTensor(
      resizedImage,
    );

    final debugImage =
        imageToJpeg(
      resizedImage,
      quality: 90,
    );

    return ProcessedImageResult(
      tensor: tensor,
      debugImage: debugImage,
      brightness: brightness,
      isLowLight: lowLight,
    );
  }
}

class ProcessedImageResult {
  final List<List<List<List<double>>>>
      tensor;

  final Uint8List debugImage;

  final double brightness;

  final bool isLowLight;

  const ProcessedImageResult({
    required this.tensor,
    required this.debugImage,
    required this.brightness,
    required this.isLowLight,
  });
}