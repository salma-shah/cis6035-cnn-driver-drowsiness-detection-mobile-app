import 'package:sleepy_driver/safety_tips/models/safety_tip.dart';

enum SafetyTipStatus {
  initial,
  loading,
  loaded,
  error,
}

class SafetyTipState {
  final SafetyTipStatus status;
  final List<SafetyTip> tips;
  final String? errorMessage;

  const SafetyTipState({
    this.status = SafetyTipStatus.initial,
    this.tips = const [],
    this.errorMessage,
  });

  SafetyTipState copyWith({
    SafetyTipStatus? status,
    List<SafetyTip>? tips,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SafetyTipState(
      status:
          status ?? this.status,
      tips:
          tips ?? this.tips,
      errorMessage:
          clearError
              ? null
              : errorMessage ??
                  this.errorMessage,
    );
  }
}