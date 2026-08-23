import 'package:sleepy_driver/alarm_system/alarm_lvl.dart';
import 'package:sleepy_driver/alarm_system/services/audio_service.dart';
import 'package:sleepy_driver/alarm_system/services/notif_service.dart';
import 'package:sleepy_driver/alarm_system/services/vibration_service.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class AlarmFacade {
  final AudioService audioService;
  final VibrationService vibrationService;
  final NotifService notificationService;

  AlarmLevel currentLevel = AlarmLevel.none;

  AlarmFacade({
    required this.audioService,
    required this.vibrationService,
    required this.notificationService,
  });

// initializing everything
  Future<void> initialize() async {
    await audioService.initialize();
    await vibrationService.initialize();
    await notificationService.initialize();
  }

  // triggering alarm 
  Future<void> triggerAlarm(FatigueSeverity severity) async 
  {
    switch(severity)
    {
      case FatigueSeverity.normal:
      await stop();
      break;

      case FatigueSeverity.mild:
      await audioService.playMild();
      await vibrationService.mild();
      break;

      case FatigueSeverity.moderate:
      await audioService.playWarning();
      await vibrationService.warning();
      await notificationService.showWarning();
      break;
      
      case FatigueSeverity.severe:
      await audioService.playCritical();
      await vibrationService.critical();
      await notificationService.showCritical();
      break;
    }
  }


  Future<void> warning() async {
    if (currentLevel ==
        AlarmLevel.warning) {
      return;
    }

    if (currentLevel == AlarmLevel.minor)
    {
      return;
    }
    if (currentLevel ==
        AlarmLevel.critical) {
      return;
    }

    currentLevel =
        AlarmLevel.warning;

    await audioService.playWarning();
    await vibrationService.warning();
    await notificationService.showWarning();
  }

  Future<void> critical() async {
    if (currentLevel ==
        AlarmLevel.critical) {
      return;
    }
    if (currentLevel ==
        AlarmLevel.warning) {
      return;
    }

    if (currentLevel == AlarmLevel.minor)
    {
      return;
    }

    currentLevel = AlarmLevel.critical;

    await audioService.playCritical();
    await vibrationService.critical();
    await notificationService.showCritical();
  }

   Future<void> minor() async {
    if (currentLevel ==
        AlarmLevel.minor) {
      return;
    }
    if (currentLevel ==
        AlarmLevel.critical) {
      return;
    }

    if (currentLevel == AlarmLevel.minor)
    {
      return;
    }

    currentLevel = AlarmLevel.minor;

    await audioService.playMild();
    await vibrationService.mild();
   // await notificationService.showMild();
  }


// stop alarms
  Future<void> stop() async {
    if (currentLevel ==
        AlarmLevel.none) {
      return;
    }

    currentLevel = AlarmLevel.none;
    await audioService.stop();
    await vibrationService.stop();
    await notificationService.cancelAll();
  }

// dispose everything and stop
  Future<void> dispose() async {
    await stop();
    await audioService.dispose();
    await vibrationService.dispose();
  }
}