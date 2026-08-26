import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/alarm_system/models/drowsiness_alert.dart';
import 'package:sleepy_driver/alarm_system/repos/alert_repo.dart';
import 'package:sleepy_driver/alarm_system/viewmodels/bloc/alerts_event.dart';
import 'package:sleepy_driver/alarm_system/viewmodels/bloc/alerts_state.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class DrowsinessAlertBloc
    extends Bloc<
        DrowsinessAlertEvent,
        DrowsinessAlertState> {
  final DrowsinessAlertRepo repository;

  DrowsinessAlertBloc({
    required this.repository,
  }) : super(
          const DrowsinessAlertState(),
        ) {
    on<SaveDrowsinessAlert>(
      saveDrowsinessAlert,
    );

    on<LoadTripDrowsinessAlerts>(
      loadTripAlerts,
    );

    on<LoadUserDrowsinessAlerts>(
      loadUserAlerts,
    );

    on<AcknowledgeDrowsinessAlert>(
      acknowledgeAlert,
    );
  }

  // save alert
  Future<void> saveDrowsinessAlert(
    SaveDrowsinessAlert event,
    Emitter<DrowsinessAlertState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status:
              DrowsinessAlertStatus.loading,
          clearError: true,
        ),
      );

      final alert =
          DrowsinessAlert(
        alertId: '',
        userId: '',
        tripId: event.tripId,
        timestamp: DateTime.now(),
        severity:
            _severityToString(
          event.severity,
        ),
        durationSeconds:
            event.durationSeconds,
        cnnProbability:
            event.cnnProbability,
        ear: event.ear,
        mar: event.mar,
        acknowledged: false,
      );

      final alertId =
          await repository.createAlert(
        alert,
      );

      emit(
        state.copyWith(
          status:
              DrowsinessAlertStatus.saved,
          lastCreatedAlertId:
              alertId,
          clearError: true,
        ),
      );

      log(
        'Alert saved: $alertId',
        name: 'DrowsinessAlertBloc',
      );
    } catch (e, stackTrace) {
      log(
        'Failed to save drowsiness alert.',
        name: 'DrowsinessAlertBloc',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status:
              DrowsinessAlertStatus.error,
          errorMessage:
              'Unable to save drowsiness alert.',
        ),
      );
    }
  }

  Future<void> loadTripAlerts(
    LoadTripDrowsinessAlerts event,
    Emitter<DrowsinessAlertState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            DrowsinessAlertStatus.loading,
        clearError: true,
      ),
    );

    await emit.forEach<
        List<DrowsinessAlert>>(
      repository.getTripAlerts(
        event.tripId,
      ),
      onData: (alerts) {
        return state.copyWith(
          status:
              DrowsinessAlertStatus.loaded,
          alerts: alerts,
          clearError: true,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
          status:
              DrowsinessAlertStatus.error,
          errorMessage:
              'Unable to load trip alerts.',
        );
      },
    );
  }


  Future<void> loadUserAlerts(
    LoadUserDrowsinessAlerts event,
    Emitter<DrowsinessAlertState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            DrowsinessAlertStatus.loading,
        clearError: true,
      ),
    );

    await emit.forEach<
        List<DrowsinessAlert>>(
      repository.getCurrentUserAlerts(),
      onData: (alerts) {
        return state.copyWith(
          status:
              DrowsinessAlertStatus.loaded,
          alerts: alerts,
          clearError: true,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
          status:
              DrowsinessAlertStatus.error,
          errorMessage:
              'Unable to load drowsiness alerts.',
        );
      },
    );
  }

  Future<void> acknowledgeAlert(
    AcknowledgeDrowsinessAlert event,
    Emitter<DrowsinessAlertState> emit,
  ) async {
    try {
      await repository.acknowledgeAlert(
        event.alertId,
      );
    } catch (e, stackTrace) {
      log(
        'Failed to acknowledge alert.',
        name: 'DrowsinessAlertBloc',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status:
              DrowsinessAlertStatus.error,
          errorMessage:
              'Unable to acknowledge alert.',
        ),
      );
    }
  }

  // helper for formatting 
  String _severityToString(
    FatigueSeverity severity,
  ) {
    switch (severity) {
      case FatigueSeverity.normal:
        return 'normal';

      case FatigueSeverity.mild:
        return 'mild';

      case FatigueSeverity.moderate:
        return 'moderate';

      case FatigueSeverity.severe:
        return 'severe';
    }
  }
}