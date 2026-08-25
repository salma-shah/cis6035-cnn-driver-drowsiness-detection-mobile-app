import '../../../drowsiness_detection/fatigue_severity.dart';

abstract class DrowsinessAlertEvent {
  const DrowsinessAlertEvent();
}

class SaveDrowsinessAlert extends DrowsinessAlertEvent {
  final String tripId;
  final FatigueSeverity severity;
  final int durationSeconds;
  final double cnnProbability;
  final double? ear;
  final double? mar;

  const SaveDrowsinessAlert({
    required this.tripId,
    required this.severity,
    required this.durationSeconds,
    required this.cnnProbability,
    required this.ear,
    required this.mar,
  });
}

// load alerts belonging to one trip
class LoadTripDrowsinessAlerts extends DrowsinessAlertEvent {
  final String tripId;
  const LoadTripDrowsinessAlerts(
    this.tripId,
  );
}

// load all alerts for current user
class LoadUserDrowsinessAlerts extends DrowsinessAlertEvent {
  const LoadUserDrowsinessAlerts();
}

// mark an alert as acknowledged
class AcknowledgeDrowsinessAlert extends DrowsinessAlertEvent {
  final String alertId;

  const AcknowledgeDrowsinessAlert(
    this.alertId,
  );
}