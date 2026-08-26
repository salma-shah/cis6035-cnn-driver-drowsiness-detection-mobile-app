import 'package:sleepy_driver/alarm_system/models/drowsiness_alert.dart';

abstract class DrowsinessAlertServiceInterface {
  Future<String> createAlert(
    DrowsinessAlert alert,
  );

  Future<DrowsinessAlert?> getAlert(
    String alertId,
  );

  Stream<List<DrowsinessAlert>> getTripAlerts(
    String tripId,
  );

  Stream<List<DrowsinessAlert>> getCurrentUserAlerts();

  Future<void> acknowledgeAlert(
    String alertId,
  );
}