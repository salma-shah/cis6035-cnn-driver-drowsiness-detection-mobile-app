enum BreakStatus {
  initial,
  active,
  completed,
  error,
}

class BreakState {
  final BreakStatus status;
  final String? breakId;
  final DateTime? startTime;
  final String? errorMessage;

  const BreakState({
    this.status = BreakStatus.initial,
    this.breakId,
    this.startTime,
    this.errorMessage,
  });

  BreakState copyWith({
    BreakStatus? status,
    String? breakId,
    DateTime? startTime,
    String? errorMessage,
    bool clearBreak = false,
  }) {
    return BreakState(
      status: status ?? this.status,

      breakId: clearBreak
          ? null
          : breakId ?? this.breakId,

      startTime: clearBreak
          ? null
          : startTime ?? this.startTime,

      errorMessage:
          errorMessage ?? this.errorMessage,
    );
  }
}