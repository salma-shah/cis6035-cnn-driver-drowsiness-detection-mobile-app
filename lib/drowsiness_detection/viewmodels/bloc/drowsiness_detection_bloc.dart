import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/alarm_system/facade/alarm_facade.dart';

import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/drowsiness_detection/models/drowsiness_result.dart';
import 'package:sleepy_driver/drowsiness_detection/repos/drowsiness_detection_repo.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_event.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_state.dart';

class DrowsinessBloc
    extends Bloc<DrowsinessEvent, DrowsinessState> {
      DateTime? lastAlarmDismissedAt;
      bool alarmRearmed = true;
      final Duration alarmCooldown = const Duration(seconds: 10);
    
  final DrowsinessDetectionRepo repository;
  final AlarmFacade alarmFacade;

  DrowsinessBloc({
    required this.repository,
    required this.alarmFacade,
  }) : super(const DrowsinessState()) {

    on<DrowsinessInitialize>(
      onInitialize,
    );

    on<DrowsinessStartMonitoring>(
      onStartMonitoring,
    );

    on<DrowsinessStopMonitoring>(
      onStopMonitoring,
    );

    on<DrowsinessPredictionReceived>(
      onPredictionReceived,
    );

    on<DrowsinessErrorOccurred>(
      onErrorOccurred,
    );

    on<DrowsinessAlarmDismissed>(
      onAlarmDismissed,
    );
  }

  Future<void> onInitialize(
    DrowsinessInitialize event,
    Emitter<DrowsinessState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: DrowsinessStatus.initializing,
          clearError: true,
        ),
      );

      await repository.initialize();

      final cameraController = repository.cameraController;

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
          errorMessage: 'Something went wrong. We apologize.',
        ),
      );
    }
  }

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

      log(
        'BLoC: Starting drowsiness monitoring...',
      );

      // make sure previous alarm state are cleared
      await alarmFacade.stop();

      emit(
        state.copyWith(
          status: DrowsinessStatus.monitoring,
          alarmActive: false,
          severity: FatigueSeverity.normal,
          clearError: true,
        ),
      );

      await repository.startMonitoring(
        onPrediction: (DrowsinessResult result) {
          add(
            DrowsinessPredictionReceived(
              result,
            ),
          );
        },
        onError: (Object error) {
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
          status: DrowsinessStatus.error,
          errorMessage: 'Something went wrong. We apologize.',
        ),
      );
    }
  }

  Future<void> onStopMonitoring(
    DrowsinessStopMonitoring event,
    Emitter<DrowsinessState> emit,
  ) async {
    try {
      log(
        'BLoC: Stopping drowsiness monitoring...',
      );

      await repository.stopMonitoring();

      // always stop alarm when monitoring ends
      await alarmFacade.stop();

      emit(
        state.copyWith(
          status: DrowsinessStatus.stopped,
          probability: 0.0,
          ear: null,
          mar: null,
          isDrowsy: false,
          label: 'Normal',
          severity: FatigueSeverity.normal,
          alarmActive: false,
          clearError: true,
        ),
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
          errorMessage: 'Something went wrong. We apologize.',
        ),
      );
    }
  }

Future<void> onPredictionReceived(
  DrowsinessPredictionReceived event,
  Emitter<DrowsinessState> emit,
) async {
  final result = event.result;

  try {
    // always update  detection state
    emit(
      state.copyWith(
        status: DrowsinessStatus.monitoring,
        probability: result.probability,
        ear: result.ear,
        mar: result.mar,
        isDrowsy: result.isDrowsy,
        label: result.label,
        severity: result.severity,
        clearError: true,
      ),
    );

    // when non drowsy no alarms

    if (!result.isDrowsy ||
        result.severity == FatigueSeverity.normal) {
      alarmRearmed = true;
      return;
    }

    if (alarmFacade.isAlarmActive) {
      return;
    }

    // if driver dismissed previous alarm but  is still drowsy
    // don't imediatelt restart

    if (!alarmRearmed) {
      return;
    }

    // trigger alarm
    alarmRearmed = false;
    emit(
      state.copyWith(
        alarmActive: true,
      ),
    );

    await alarmFacade.triggerAlarm(
      severity: result.severity,
    );

  } catch (e, stackTrace) {
    log(
      'BLoC prediction/alarm error: $e',
      stackTrace: stackTrace,
    );

    emit(
      state.copyWith(
        alarmActive: false,
        status: DrowsinessStatus.error,
        errorMessage: e.toString(),
      ),
    );
  }
}

Future<void> onAlarmDismissed(
  DrowsinessAlarmDismissed event,
  Emitter<DrowsinessState> emit,
) async {
  try {
    log('BLoC: User dismissed alarm.');

    await alarmFacade.stop();

    // the driver must first return to NON-DROWSY
    emit(
      state.copyWith(
        alarmActive: false,
      ),
    );

  } catch (e, stackTrace) {
    log(
      'BLoC alarm dismissal error: $e',
      stackTrace: stackTrace,
    );
  }
}


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
    await alarmFacade.stop();
    await repository.dispose();

    return super.close();
  }
}