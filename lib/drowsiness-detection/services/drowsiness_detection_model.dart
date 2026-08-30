import 'package:tflite_flutter/tflite_flutter.dart';

class DrowsinessDetectionModel {
  late Interpreter interpreter;
  bool isLoaded = false;
  
  // loading the model
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset(
      'assets/models/tflite_sleepydriver_model.tflite',
    );

    isLoaded = true;

    // debugging
    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);

    print('Input shape: ${inputTensor.shape}');
    print('Input type: ${inputTensor.type}');
    print('Output shape: ${outputTensor.shape}');
    print('Output type: ${outputTensor.type}');

  }

  double predict(List input)
  {
    if (!isLoaded)
    {
      throw Exception("TFLite model has not been loaded");
    }
     final output = List.filled(
    1,
    0.0,
  ).reshape([1, 1]);

  interpreter.run(
    input,
    output,
  );

    // final nonDrowsyProbability = output[0][0];
    // final drowsinessProbability =
    //     1.0 - nonDrowsyProbability;

  return output[0][0];
 // return drowsinessProbability;
  }

  // getting the probability label
  bool isDrowsy(double drowsinessProbability)
  {
    return drowsinessProbability > 0.5;
  }

  String getDrowsinessLabel(double drowsinessProbability)
  {
    if (drowsinessProbability > 0.5) {
      return 'Drowsy';
    }

    return 'Non Drowsy';
  }

   void dispose() {
    if (isLoaded) {
      interpreter.close();
      isLoaded = false;
    }
  }
}