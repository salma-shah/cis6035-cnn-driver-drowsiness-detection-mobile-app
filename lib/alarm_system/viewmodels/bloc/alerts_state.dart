import '../../models/drowsiness_alert.dart';

enum DrowsinessAlertStatus {
  initial,
  loading,
  loaded,
  saved,
  error,
}

class DrowsinessAlertState {
  final DrowsinessAlertStatus status;
  final List<DrowsinessAlert> alerts;
  final String? lastCreatedAlertId;
  final String? errorMessage;

  const DrowsinessAlertState({
    this.status =
        DrowsinessAlertStatus.initial,
    this.alerts = const [],
    this.lastCreatedAlertId,
    this.errorMessage,
  });

  DrowsinessAlertState copyWith({
    DrowsinessAlertStatus? status,
    List<DrowsinessAlert>? alerts,
    String? lastCreatedAlertId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DrowsinessAlertState(
      status:
          status ?? this.status,
      alerts:
          alerts ?? this.alerts,
      lastCreatedAlertId:
          lastCreatedAlertId ??
              this.lastCreatedAlertId,
      errorMessage:
          clearError
              ? null
              : errorMessage ??
                  this.errorMessage,
    );
  }
}