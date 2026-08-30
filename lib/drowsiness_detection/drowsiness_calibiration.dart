class DrowsinessCalibration {
  final double earBaseline;
  final double marBaseline;
  final double earThreshold;
  final double marThreshold;
  final int sampleCount;

  const DrowsinessCalibration({
    required this.earBaseline,
    required this.marBaseline,
    required this.earThreshold,
    required this.marThreshold,
    required this.sampleCount,
  });
}

class DrowsinessCalibrator {
  final List<double> earSamples = [];
  final List<double> marSamples = [];

  bool isCalibrating = false;
  DrowsinessCalibration? calibration;
  final int minimumSamples;
  final double earMultiplier;
  final double marMultiplier;

  DrowsinessCalibrator({
    this.minimumSamples = 30,
    // ear decreases when eyes close
    this.earMultiplier = 0.75,
    // mar increases when mouth opens
    this.marMultiplier = 1.50,
  });

  // start calibration

  void start() {
    earSamples.clear();
    marSamples.clear();

    calibration = null;

    isCalibrating = true;
  }

  bool get isItCalibrating =>
      isCalibrating;

  bool get isCalibrated =>
      calibration != null;

  DrowsinessCalibration? get calibrationValues =>
      calibration;

  int get sampleCount =>
      earSamples.length;

  bool get hasEnoughSamples =>
      earSamples.length >= minimumSamples;


  void addSample({
    required double ear,
    required double mar,
  }) {
    if (!isCalibrating) {
      return;
    }

    // only valid values 
    if (!ear.isFinite ||
        !mar.isFinite) {
      return;
    }

    if (ear <= 0 ||
        mar < 0) {
      return;
    }

    earSamples.add(ear);
    marSamples.add(mar);
  }

  // end calibration and return baseline values
  DrowsinessCalibration? finish() {
    if (!isCalibrating) {
      return calibration;
    }

    if (!hasEnoughSamples) {
      return null;
    }

    final earBaseline =
        median(earSamples);

    final marBaseline =
        median(marSamples);
    final earThreshold =
        earBaseline * earMultiplier;
    final marThreshold =
        marBaseline * marMultiplier;

    calibration =
        DrowsinessCalibration(
      earBaseline: earBaseline,
      marBaseline: marBaseline,
      earThreshold: earThreshold,
      marThreshold: marThreshold,
      sampleCount: earSamples.length,
    );

    isCalibrating = false;
    return calibration;
  }


  void reset() {
    earSamples.clear();
    marSamples.clear();
    calibration = null;
    isCalibrating = false;
  }

  // median is more suitable so that extreme values do not affect it
  double median(List<double> values) {
    if (values.isEmpty) {
      throw StateError(
        'Cannot calculate median of empty list.',
      );
    }

    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {return sorted[middle];}
    return (sorted[middle - 1] + sorted[middle]) / 2;
  }
}