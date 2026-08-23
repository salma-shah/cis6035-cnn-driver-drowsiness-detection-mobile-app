import 'dart:developer';

import 'package:sleepy_driver/alarm_system/services/audio_service.dart';
import 'package:sleepy_driver/alarm_system/services/notif_service.dart';
import 'package:sleepy_driver/alarm_system/services/vibration_service.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class AlarmFacade {
  final AudioService audioService;
  final VibrationService vibrationService;
  final NotifService notificationService;

  bool _alarmActive = false;

  bool get isAlarmActive => _alarmActive;

  AlarmFacade({
    required this.audioService,
    required this.vibrationService,
    required this.notificationService,
  });

  Future<void> initialize() async {
    await audioService.initialize();
    await vibrationService.initialize();
    await notificationService.initialize();
  }

  Future<void> triggerAlarm({
    required FatigueSeverity severity,
  }) async {
    // DO NOT restart an already active alarm.
    if (_alarmActive) {
      return;
    }

    if (severity == FatigueSeverity.normal) {
      return;
    }

    // Set this BEFORE starting any async alarm work.
    _alarmActive = true;

    try {
      switch (severity) {
        case FatigueSeverity.normal:
          break;

        case FatigueSeverity.mild:
          await audioService.playMild();
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
      _alarmActive = false;
      rethrow;
    }
  }

Future<void> stop() async {
  log('ALARM FACADE STOP');
  _alarmActive = false;

  log('STOPPING AUDIO');
  await audioService.stop();

  log('STOPPING VIBRATION');
  await vibrationService.stop();

  log('CANCELLING NOTIFICATION');
  await notificationService.cancelAll();

  log('ALARM COMPLETELY STOPPED');
}
  Future<void> dispose() async {
    await stop();

    await audioService.dispose();
    await vibrationService.dispose();
    await notificationService.dispose();
  }
}