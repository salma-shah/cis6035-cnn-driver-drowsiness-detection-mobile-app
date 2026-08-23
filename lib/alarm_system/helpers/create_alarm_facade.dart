import 'package:sleepy_driver/alarm_system/facade/alarm_facade.dart';
import 'package:sleepy_driver/alarm_system/services/audio_service.dart';
import 'package:sleepy_driver/alarm_system/services/notif_service.dart';
import 'package:sleepy_driver/alarm_system/services/vibration_service.dart';

AlarmFacade createAlarmFacade() {
  return AlarmFacade(
    audioService: AudioService(),
    notificationService: NotifService(),
    vibrationService: VibrationService(),
  );
}