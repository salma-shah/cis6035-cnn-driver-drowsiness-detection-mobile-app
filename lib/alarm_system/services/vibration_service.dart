// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:vibration/vibration.dart';
// import 'package:vibration/vibration_presets.dart';

// class AlarmVibrationService {
//   bool isVibrating = false;

//   Future<void> initialize() async {
//     debugPrint('Vibration initialized');
//   }

//   Future<void> warning() async {
//     if (isVibrating) return;

//     isVibrating = true;
//     log('WARNING VIBRATION');
    
//     // checking if phone has vibrator
//     if (await Vibration.hasVibrator())
//     {
//       Vibration.vibrate(preset: VibrationPreset.tripleBuzz);
//     }    
//   }

//   Future<void> critical() async {
//     if (isVibrating) return;
//     isVibrating = true;
//     log('CRITICAL VIBRATION');
//     if (await Vibration.hasVibrator())
//     {
//       Vibration.vibrate(preset: VibrationPreset.emergencyAlert);
//     }  
//   }

//   Future<void> stop() async {
//     if (!isVibrating) return;
//     isVibrating = false;
//     log('Vibration stopped');
//     if (await Vibration.hasVibrator())
//     {
//       Vibration.cancel();
//     }  
//   }

//   Future<void> dispose() async {
//     await stop();
//   }
// }

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