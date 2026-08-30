import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/alarm_system/facade/alarm_facade.dart';
import 'package:sleepy_driver/alarm_system/models/drowsiness_alert.dart';
import 'package:sleepy_driver/alarm_system/repos/alert_repo.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/drowsiness_detection/repos/drowsiness_detection_repo.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_event.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_state.dart';

class DrowsinessBloc
    extends Bloc<DrowsinessEvent, DrowsinessState> {
  final DrowsinessDetectionRepo repository;
  final DrowsinessAlertRepo alertRepository;
  final AlarmFacade alarmFacade;
  bool alarmRearmed = true;
  Timer? _tripTimer;
  
  DrowsinessBloc({
    required this.repository, required this.alertRepository,
    required this.alarmFacade,
  }) : super(const DrowsinessState()) {
    on<DrowsinessInitialize>(
      onInitialize,
    );

    on<DrowsinessStartMonitoring>(
      onStartMonitoring,
    );

    on<DrowsinessStopMonitoring>(
      onStopMonitoring
    );

    on<DrowsinessPredictionReceived>(
      onPredictionReceived
    );

    on<DrowsinessErrorOccurred>(
      onErrorOccurred
    );

    on<DrowsinessAlarmDismissed>(
      onAlarmDismissed
    );

    on<DrowsinessTripTimerTick>(
      onTripTimerTick
    );

    on<DrowsinessBreakStarted>(
      onBreakStarted
      );
    
    on<DrowsinessBreakEnded>( 
        onBreakEnded);
  }

  Future<void> onInitialize(
    DrowsinessInitialize event,
    Emitter<DrowsinessState> emit,
  ) async {
    if (state.status == DrowsinessStatus.monitoring ||
        state.status == DrowsinessStatus.initializing) {
      log(
        'BLoC: Initialization ignored because detection '
        'is already active/initializing.',
      );

      return;
    }

    if (state.status == DrowsinessStatus.ready) {
      log(
        'BLoC: Detection is already ready.',
      );

      return;
    }

    try {
      emit(
        state.copyWith(
          status: DrowsinessStatus.initializing,
          clearError: true,
        ),
      );

      await repository.initialize();

      final cameraController =
          repository.cameraController;

      if (cameraController == null) {
        throw Exception(
          'Camera initialized but CameraController is null.',
        );
      }

      emit(
        state.copyWith(
          status: DrowsinessStatus.ready,
          cameraController: cameraController,
          clearError: true,
        ),
      );

      log(
        'BLoC: Drowsiness detection ready.',
      );
    } catch (e, stackTrace) {
      log(
        'BLoC initialization error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: DrowsinessStatus.error,
          errorMessage:
              'Something went wrong. We apologize.',
        ),
      );
    }
  }

  // start the monitoring
Future<void> onStartMonitoring(
  DrowsinessStartMonitoring event,
  Emitter<DrowsinessState> emit,
) async {
  try {
    if (!repository.isCameraInitialized) {
      throw Exception(
        'Drowsiness detection is not initialized.',
      );
    }

    if (state.status ==
        DrowsinessStatus.monitoring) {
      return;
    }

    await alarmFacade.stop();

    alarmRearmed = true;

    final startTime = event.startTime;

    emit(
      state.copyWith(
        status:
            DrowsinessStatus.monitoring,

        tripId: event.tripId,

        tripStartTime: startTime,
        tripDuration: Duration.zero,

        alarmActive: false,
        severity:
            FatigueSeverity.normal,

        totalDrowsinessEvents: 0,
        totalAlerts: 0,
        maxSeverity:
            FatigueSeverity.normal,

        clearError: true,
      ),
    );

    // timer
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!isClosed) {
          add(
            const DrowsinessTripTimerTick(),
          );
        }
      },
    );

    await repository.startMonitoring(
      onPrediction: (result) {
        add(
          DrowsinessPredictionReceived(
            result,
          ),
        );
      },
      onError: (error) {
        add(
          DrowsinessErrorOccurred(
            error.toString(),
          ),
        );
      },
    );
  } catch (e, stackTrace) {
    log(
      'BLoC start monitoring error: $e',
      stackTrace: stackTrace,
    );

    emit(
      state.copyWith(
        status:
            DrowsinessStatus.error,
        errorMessage:
            'Something went wrong. We apologize.',
      ),
    );
  }
}

  // trip timer
  void onTripTimerTick(
    DrowsinessTripTimerTick event,
    Emitter<DrowsinessState> emit,
  ) {
    if (state.status !=
        DrowsinessStatus.monitoring) {
      return;
    }

    final startTime = state.tripStartTime;

    if (startTime == null) {
      return;
    }

    final duration =
        DateTime.now().difference(startTime);

    emit(
      state.copyWith(
        tripDuration: duration,
      ),
    );
  }

// prediction recieveed
Future<void> onPredictionReceived(
  DrowsinessPredictionReceived event,
  Emitter<DrowsinessState> emit,
) async {
  final result = event.result;

  try {
    final wasDrowsy = state.isDrowsy;

    final isNowDrowsy =
        result.isDrowsy &&
        result.severity != FatigueSeverity.normal;

    // new drowsy event
    final isNewDrowsinessEvent =
        !wasDrowsy && isNowDrowsy;

    int updatedDrowsinessEvents =
        state.totalDrowsinessEvents;

    if (isNewDrowsinessEvent) {
      updatedDrowsinessEvents++;

      log(
        'BLoC: New drowsiness event #'
        '$updatedDrowsinessEvents',
      );
    }

    FatigueSeverity updatedMaxSeverity =
    state.maxSeverity;

if (severityRank(result.severity) >
    severityRank(updatedMaxSeverity)) {
  updatedMaxSeverity =
      result.severity;
}

    // update detection state without fail
    emit(
      state.copyWith(
        status: DrowsinessStatus.monitoring,
        probability: result.probability,
        ear: result.ear,
        mar: result.mar,
        isDrowsy: result.isDrowsy,
        label: result.label,
        severity: result.severity,
        totalDrowsinessEvents:updatedDrowsinessEvents,
        maxSeverity: updatedMaxSeverity,
        clearError: true,
     //   debugImage: result.debugImage,
      ),
    );

    // during a break, only detection continues, not alarm
    if (state.onBreak) { return;}

    if (!isNowDrowsy) {
      alarmRearmed = true;
      return;
    }

    // if alarm is already ringing, no alarm again
    if (alarmFacade.isAlarmActive) {
      return;
    }

    if (state.alarmActive) {
      return;
    }

    if (!alarmRearmed) {
      return;
    }

    alarmRearmed = false;
    final updatedAlerts =
    state.totalAlerts + 1;

emit(
  state.copyWith(
    alarmActive: true,
    totalAlerts: updatedAlerts,
  ),
);

    log(
      'BLoC: Alarm #$updatedAlerts triggered: '
      '${result.severity}',
    );

    log(
  'ALERT DEBUG → '
  'tripId=${state.tripId}, '
  'severity=${result.severity}, '
  'cnn=${result.probability}, '
  'ear=${result.ear}, '
  'mar=${result.mar}',
);

    if (state.tripId != null) {
      try {
        final alert =
            DrowsinessAlert(
          alertId: '',
          userId: '',
          tripId: state.tripId!,
          timestamp:DateTime.now(),
          severity:severityToString(result.severity),
          durationSeconds:result.drowsinessDuration.inSeconds,
          cnnProbability:result.probability,
          ear: result.ear,
          mar: result.mar,
          acknowledged: false
        );

        await alertRepository.createAlert(
          alert,
        );

        log(
          'BLoC: Drowsiness alert saved.',
        );
      } catch (e, stackTrace) {
        log(
          'Failed to save drowsiness alert: $e',
          stackTrace: stackTrace,
        );
      }
    } else {
      log(
        'No active Trip ID. Alert was not saved.',
      );
    }

    // starting the alarm
    await alarmFacade.triggerAlarm(
      severity: result.severity,
    );
  } catch (e, stackTrace) {
    log(
      'BLoC prediction/alarm error: $e',
      stackTrace: stackTrace,
    );
    alarmRearmed = true;
    emit(
      state.copyWith(
        alarmActive: false,
        status: DrowsinessStatus.error,
        errorMessage:
            'Something went wrong. We apologize.',
      ),
    );
  }
}

  // dismiss the alarm
  Future<void> onAlarmDismissed(
    DrowsinessAlarmDismissed event,
    Emitter<DrowsinessState> emit,
  ) async {
    try {
      log(
        'BLoC: User dismissed alarm.',
      );

      await alarmFacade.stop();

      emit(
        state.copyWith(
          alarmActive: false,
        ),
      );

      log(
        'BLoC: Alarm stopped by user.',
      );
    } catch (e, stackTrace) {
      log(
        'BLoC alarm dismissal error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          alarmActive: false,
          status: DrowsinessStatus.error,
          errorMessage:
              'Unable to stop the alarm.',
        ),
      );
    }
  }

// stopping monitoring but keeping the important data to save into table -> start monitoring starts afresh anyway
  Future<void> onStopMonitoring(
    DrowsinessStopMonitoring event,
    Emitter<DrowsinessState> emit,
  ) async {
    try {
      log(
        'BLoC: Stopping drowsiness monitoring...',
      );

      // stop everything.
      _tripTimer?.cancel();
      _tripTimer = null;
      await repository.stopMonitoring();
      await alarmFacade.stop();

      alarmRearmed = true;
      // keeping the important statistics 
    emit(
  state.copyWith(
    status: DrowsinessStatus.stopped,
    tripId: state.tripId,
    tripStartTime: state.tripStartTime,
    probability: 0.0,
    ear: null,
    mar: null,
    isDrowsy: false,
    label: 'Normal',
    severity: FatigueSeverity.normal,
    alarmActive: false,
    totalDrowsinessEvents:
        state.totalDrowsinessEvents,

    totalAlerts:
        state.totalAlerts,

    maxSeverity:
        state.maxSeverity,

    tripDuration:
        state.tripDuration,

    clearError: true,
  )
);

      log(
        'BLoC: Drowsiness monitoring stopped.',
      );
    } catch (e, stackTrace) {
      log(
        'BLoC stop monitoring error: $e',
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: DrowsinessStatus.error,
          errorMessage:
              'Something went wrong. We apologize.',
        ),
      );
    }
  }

  // error and closing
  void onErrorOccurred(
    DrowsinessErrorOccurred event,
    Emitter<DrowsinessState> emit,
  ) {
    log(
      'BLoC: Detection error: ${event.message}',
    );

    emit(
      state.copyWith(
        status: DrowsinessStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    _tripTimer?.cancel();
    _tripTimer = null;

    await alarmFacade.stop();
    await repository.dispose();

    return super.close();
  }
  
String severityToString(
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

  int severityRank(
    FatigueSeverity? severity,
  ) {
    switch (severity) {
      case FatigueSeverity.normal:
        return 0;

      case FatigueSeverity.mild:
        return 1;

      case FatigueSeverity.moderate:
        return 2;

      case FatigueSeverity.severe:
        return 3;

      case null:
        return 0;
    }
  }

  Future<void> onBreakStarted(
  DrowsinessBreakStarted event,
  Emitter<DrowsinessState> emit,
) async {
  log(
    'BLoC: Driver break started.',
  );

  await alarmFacade.stop();

  alarmRearmed = true;

  emit(
    state.copyWith(
      onBreak: true,
      alarmActive: false,
    ),
  );
}

void onBreakEnded(
  DrowsinessBreakEnded event,
  Emitter<DrowsinessState> emit,
) {
  log(
    'BLoC: Driver break ended.',
  );

  // don't immediately trigger an alarm after a break
  alarmRearmed = true;
  emit(
    state.copyWith(
      onBreak: false,
    ),
  );
}
}