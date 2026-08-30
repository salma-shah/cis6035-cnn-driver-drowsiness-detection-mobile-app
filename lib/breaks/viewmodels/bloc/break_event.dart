abstract class BreakEvent {
  const BreakEvent();
}

class StartBreak extends BreakEvent {
  final String tripId;

  const StartBreak({
    required this.tripId,
  });
}

class EndBreak extends BreakEvent {
  const EndBreak();
}