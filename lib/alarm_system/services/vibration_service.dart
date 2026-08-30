import 'package:vibration/vibration.dart';

class VibrationService {
  Future<void> initialize() async {
    final hasVibrator =
        await Vibration.hasVibrator();

    if (!hasVibrator) {
      return;
    }
  }

  Future<void> mild() async {
    final hasVibrator =
        await Vibration.hasVibrator();

    if (!hasVibrator) return;

    await Vibration.vibrate(
      pattern: [
        0,
        100,
        150,
        200,
      ],
    );
  }

  Future<void> warning() async {
    final hasVibrator =
        await Vibration.hasVibrator();

    if (!hasVibrator) return;

    await Vibration.vibrate(
      pattern: [
        0,
        300,
        200,
        300,
      ],
    );
  }

  Future<void> critical() async {
    final hasVibrator =
        await Vibration.hasVibrator();

    if (!hasVibrator) return;

    await Vibration.vibrate(
      pattern: [
        0,
        500,
        150,
        500,
        150,
        500,
      ],
    );
  }

  Future<void> stop() async {
    await Vibration.cancel();
  }

  Future<void> dispose() async {
    await stop();
  }
}