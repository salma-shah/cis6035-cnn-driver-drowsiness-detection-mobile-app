
import 'package:sleepy_driver/drowsiness_detection/models/drowsiness_result.dart';

abstract class DrowsinessEvent {
  const DrowsinessEvent();
  List<Object?> get props => [];
}

class DrowsinessInitialize extends DrowsinessEvent {
  const DrowsinessInitialize();
}

class DrowsinessStartMonitoring extends DrowsinessEvent {
  final DateTime startTime;
  final String tripId;
  const DrowsinessStartMonitoring({
    required this.startTime, required this.tripId
  });

  @override
  List<Object?> get props => [startTime];
}
class DrowsinessStopMonitoring extends DrowsinessEvent {
  const DrowsinessStopMonitoring();
}

class DrowsinessPredictionReceived extends DrowsinessEvent {
  final DrowsinessResult result;

  const DrowsinessPredictionReceived(
    this.result,
  );
}

class DrowsinessErrorOccurred extends DrowsinessEvent {
  final String message;

  const DrowsinessErrorOccurred(
    this.message,
  );

  @override
  List<Object?> get props => [message];
}

class DrowsinessAlarmDismissed
    extends DrowsinessEvent {
  const DrowsinessAlarmDismissed();
}

class DrowsinessTripTimerTick
    extends DrowsinessEvent {
  const DrowsinessTripTimerTick();
}

class DrowsinessBreakStarted
    extends DrowsinessEvent {
  const DrowsinessBreakStarted();
}

class DrowsinessBreakEnded
    extends DrowsinessEvent {
  const DrowsinessBreakEnded();
}