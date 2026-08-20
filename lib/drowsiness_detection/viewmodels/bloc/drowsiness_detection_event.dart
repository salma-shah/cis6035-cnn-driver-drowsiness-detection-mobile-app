
abstract class DrowsinessEvent {
  const DrowsinessEvent();
  List<Object?> get props => [];
}

class DrowsinessInitialize extends DrowsinessEvent {
  const DrowsinessInitialize();
}

class DrowsinessStartMonitoring extends DrowsinessEvent {
  const DrowsinessStartMonitoring();
}

class DrowsinessStopMonitoring extends DrowsinessEvent {
  const DrowsinessStopMonitoring();
}

class DrowsinessPredictionReceived extends DrowsinessEvent {
  final double probability;

  const DrowsinessPredictionReceived(
    this.probability,
  );

  @override
  List<Object?> get props => [probability];
}

class DrowsinessErrorOccurred extends DrowsinessEvent {
  final String message;

  const DrowsinessErrorOccurred(
    this.message,
  );

  @override
  List<Object?> get props => [message];
}