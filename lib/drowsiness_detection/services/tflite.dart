import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteService {
  late Interpreter interpreter;
  bool isLoaded = false;

  /// load TFLite model
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
        'assets/models/sleepydriver_model.tflite',
      );

      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);
      print('Input shape : ${inputTensor.shape}');
      print('Input type  : ${inputTensor.type}');
      print('Output shape: ${outputTensor.shape}');
      print('Output type : ${outputTensor.type}');

      isLoaded = true;

      print('TFLite model loaded successfully.');
    } catch (e, stackTrace) {
      print('TFLite model loading failed: $e');
      print(stackTrace);

      isLoaded = false;

      rethrow;
    }
  }

  // making prediction
  double predict(
    List<List<List<List<double>>>> input,
  ) {
    if (!isLoaded) {
      throw Exception(
        'TFLite model has not been loaded.',
      );
    }

    try {
      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);

      print('========== TFLITE INFERENCE ==========');
      print('Expected input shape: ${inputTensor.shape}');
      print('Expected input type : ${inputTensor.type}');
      print('Expected output shape: ${outputTensor.shape}');
      print('Expected output type : ${outputTensor.type}');

      print(
        'Input shape provided: '
        '[${input.length}, '
        '${input[0].length}, '
        '${input[0][0].length}, '
        '${input[0][0][0].length}]',
      );

      print(
        'First pixel: '
        '${input[0][0][0]}',
      );

      final List<List<double>> output = [
        [0.0]
      ];

      interpreter.run(
        input,
        output,
      );

      print('TFLITE INFERENCE SUCCESS');
      print('RAW OUTPUT: $output');

      final double prediction = output[0][0];

      print(
        'Prediction: '
        '${prediction.toStringAsFixed(6)}',
      );

      return prediction;
    } catch (e, stackTrace) {
      print('TFLITE INFERENCE ERROR: $e');
      print(stackTrace);

      rethrow;
    }
  }

  void dispose() {
    if (isLoaded) {
      interpreter.close();
      isLoaded = false;
    }
  }
}