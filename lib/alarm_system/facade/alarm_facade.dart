import 'dart:developer';

import 'package:sleepy_driver/alarm_system/services/audio_service.dart';
import 'package:sleepy_driver/alarm_system/services/vibration_service.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class AlarmFacade {
  final AudioService audioService;
  final VibrationService vibrationService;
  bool alarmActive = false;
  bool get isAlarmActive => alarmActive;

  AlarmFacade({
    required this.audioService,
    required this.vibrationService
  });

  Future<void> initialize() async {
    await audioService.initialize();
    await vibrationService.initialize();
  }

  Future<void> triggerAlarm({
    required FatigueSeverity severity,
  }) async {
    // DO NOT restart an already active alarm.
    if (alarmActive) {
      return;
    }

    if (severity == FatigueSeverity.normal) {
      return;
    }

    // Set this BEFORE starting any async alarm work.
    alarmActive = true;

    try {
      switch (severity) {
        case FatigueSeverity.normal:
          break;

        case FatigueSeverity.mild:
        //  await audioService.playMild();
          await vibrationService.mild();
          break;

        case FatigueSeverity.moderate:
          await audioService.playWarning();
          await vibrationService.warning();
       //   await notificationService.showWarning();
          break;

        case FatigueSeverity.severe:
          await audioService.playCritical();
          await vibrationService.critical();
       //   await notificationService.showCritical();
          break;
      }
    } catch (e) {
      // if starting the alarm failed, allow another attempt
      alarmActive = false;
      rethrow;
    }
  }

Future<void> stop() async {
  log('ALARM FACADE STOP');
  alarmActive = false;

  log('STOPPING AUDIO');
  await audioService.stop();

  log('STOPPING VIBRATION');
  await vibrationService.stop();

  log('ALARM COMPLETELY STOPPED');
}
  Future<void> dispose() async {
    await stop();

    await audioService.dispose();
    await vibrationService.dispose();
  }
}