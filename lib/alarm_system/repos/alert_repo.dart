import 'package:sleepy_driver/alarm_system/services/alerts_service.dart';

import '../models/drowsiness_alert.dart';

class DrowsinessAlertRepo {
  final DrowsinessAlertServiceInterface service;

  DrowsinessAlertRepo({
    required this.service,
  });

  Future<String> createAlert(
    DrowsinessAlert alert,
  ) {
    return service.createAlert(
      alert,
    );
  }

  Future<DrowsinessAlert?> getAlert(
    String alertId
  ) {
    return service.getAlert(
      alertId,
    );
  }

  Stream<List<DrowsinessAlert>> getTripAlerts(String tripId) {
    return service.getTripAlerts(
      tripId,
    );
  }

  Stream<List<DrowsinessAlert>> getCurrentUserAlerts() {
    return service.getCurrentUserAlerts();
  }

  Future<void> acknowledgeAlert(String alertId) {
    return service.acknowledgeAlert(
      alertId,
    );
  }
}