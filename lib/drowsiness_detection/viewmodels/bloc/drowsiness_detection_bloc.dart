// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sleepy_driver/alarm_system/facade/alarm_facade.dart';
// import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

// import 'package:sleepy_driver/drowsiness_detection/models/drowsiness_result.dart';
// import 'package:sleepy_driver/drowsiness_detection/repos/drowsiness_detection_repo.dart';
// import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_event.dart';
// import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_state.dart';

// class DrowsinessBloc
//     extends Bloc<DrowsinessEvent, DrowsinessState> {
//   bool alarmActive = false;
//   final DrowsinessDetectionRepo repository;
//   final AlarmFacade alarmFacade;

//   DrowsinessBloc({
//     required this.repository, required this.alarmFacade
//   }) : super(
//           const DrowsinessState(),
//         ) {

//     on<DrowsinessInitialize>(
//       onInitialize,
//     );

//     on<DrowsinessStartMonitoring>(
//       onStartMonitoring,
//     );

//     on<DrowsinessStopMonitoring>(
//       onStopMonitoring,
//     );

//     on<DrowsinessPredictionReceived>(
//       onPredictionReceived,
//     );

//     on<DrowsinessErrorOccurred>(
//       onErrorOccurred,
//     );

//     on<DrowsinessAlarmDismissed>(
//   onAlarmDismissed,
// );
//   }

//   Future<void> onInitialize(
//     DrowsinessInitialize event,
//     Emitter<DrowsinessState> emit,
//   ) async {

//     try {
//       emit(state.copyWith(status: DrowsinessStatus.initializing,clearError: true));
//       await repository.initialize();
//       final camController = repository.cameraController;
//       if (camController == null) { throw Exception('Camera initialized but CameraController is null.');
//       }

//       emit(
//         state.copyWith(
//           status: DrowsinessStatus.ready,
//           cameraController: camController,
//           clearError: true,
//         ),
//       );

//       log('BLoC: Drowsiness detection ready.',);

//     } catch (e, stackTrace) {

//       log('BLoC initialization error: $e', stackTrace: stackTrace);

//       emit(
//         state.copyWith(
//           status: DrowsinessStatus.error,
//           errorMessage: e.toString(),
//         ),
//       );
//     }
//   }

//   Future<void> onStartMonitoring(
//     DrowsinessStartMonitoring event,
//     Emitter<DrowsinessState> emit,
//   ) async {

//     try {

//       if (!repository.isCameraInitialized) {
//         throw Exception(
//           'Drowsiness detection is not initialized.',
//         );
//       }

//       log(
//         'BLoC: Starting drowsiness monitoring...',
//       );

//       emit(
//         state.copyWith(
//           status: DrowsinessStatus.monitoring,
//           clearError: true,
//         ),
//       );

//       await repository.startMonitoring(
//         onPrediction: (
//           DrowsinessResult result,
//         ) {
//           add(
//             DrowsinessPredictionReceived(
//               result,
//             ),
//           );
//         },
//         onError: (Object error) {
//           add(
//             DrowsinessErrorOccurred(
//               error.toString(),
//             ),
//           );
//         },
//       );

//     } catch (e, stackTrace) {

//       log(
//         'BLoC start monitoring error: $e',
//         stackTrace: stackTrace,
//       );

//       emit(
//         state.copyWith(
//           status: DrowsinessStatus.error,
//           errorMessage: e.toString(),
//         ),
//       );
//     }
//   }

//   Future<void> onStopMonitoring(
//     DrowsinessStopMonitoring event,
//     Emitter<DrowsinessState> emit,
//   ) async {

//     try {
//       log(
//         'BLoC: Stopping drowsiness monitoring...',
//       );
//       await alarmFacade.stop();
//      // alarmActive = false;
//       await repository.stopMonitoring();

//       emit(
//         state.copyWith(
//           status: DrowsinessStatus.stopped,
//           probability: 0.0,
//           ear: null,
//           mar: null,
//           isDrowsy: false,
//           alarmActive: false,
//           severity: FatigueSeverity.normal,
//           label: 'Normal',
//           clearError: true,
//         ),
//       );

//       log(
//         'BLoC: Drowsiness monitoring stopped.',
//       );

//     } catch (e, stackTrace) {

//       log(
//         'BLoC stop monitoring error: $e',
//         stackTrace: stackTrace,
//       );

//       emit(
//         state.copyWith(
//           status: DrowsinessStatus.error,
//           errorMessage: e.toString(),
//         ),
//       );
//     }
//   }

//   Future<void> onPredictionReceived(
//   DrowsinessPredictionReceived event,
//   Emitter<DrowsinessState> emit,
// ) async {
//   final result = event.result;

//   emit(
//     state.copyWith(
//       status: DrowsinessStatus.monitoring,
//       probability: result.probability,
//       ear: result.ear,
//       mar: result.mar,
//       isDrowsy: result.isDrowsy,
//       label: result.label,
//       severity: result.severity,
//     //  debugProcessedImage: result.debugImage,
//       clearError: true,
//     ),
//   );

//   await handleAlarm(result, emit);
// }

//   void onErrorOccurred(
//     DrowsinessErrorOccurred event,
//     Emitter<DrowsinessState> emit,
//   ) {

//     log(
//       'BLoC: Detection error: ${event.message}',
//     );

//     emit(
//       state.copyWith(
//         status: DrowsinessStatus.error,
//         errorMessage: event.message,
//       ),
//     );
//   }


//   @override
//   Future<void> close() async {
//     await repository.dispose();
//     return super.close();
//   }

//   Future<void> onAlarmDismissed(DrowsinessAlarmDismissed event, Emitter<DrowsinessState> emit) async {
//   await alarmFacade.stop();
//  // alarmActive = false;
//   emit(
//     state.copyWith(
//       alarmActive: false,
//     ),
//   );
//   }

// Future<void> handleAlarm(
//   DrowsinessResult result,
//   Emitter<DrowsinessState> emit,
// ) async {
//   if (!result.isDrowsy) {
//     if (state.alarmActive) {
//       await alarmFacade.stop();
//     }

//     emit(
//       state.copyWith(
//         alarmActive: false,
//       ),
//     );

//     return;
//   }

//   if (state.alarmActive) {
//     return;
//   }

//  log(
//   'ALARM TRIGGERING: severity=${result.severity}',
// );

// await alarmFacade.triggerAlarm(result.severity);

// log('ALARM TRIGGERED');

//   emit(
//     state.copyWith(
//       alarmActive: true,
//     ),
//   );
// }

// }

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
          errorMessage: e.toString(),
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
          errorMessage: e.toString(),
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
          errorMessage: e.toString(),
        ),
      );
    }
  }

 Future<void> onPredictionReceived(
  DrowsinessPredictionReceived event,
  Emitter<DrowsinessState> emit,
) async {
  final result = event.result;

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

  // not drowsy so nothing to alarm
  if (!result.isDrowsy ||
      result.severity == FatigueSeverity.normal) 
      {return;}

  if (state.alarmActive) {return;}

  // cool down after alarm dismissal
  if (lastAlarmDismissedAt != null) {
    final elapsed = DateTime.now().difference(lastAlarmDismissedAt!);
    if (elapsed < alarmCooldown) {return;}
  }

  try {
    emit(
      state.copyWith(
        alarmActive: true,
        severity: result.severity,
      ),
    );

    log(
      'BLoC: Triggering ${result.severity} alarm.',
    );

    await alarmFacade.triggerAlarm(
      result.severity,
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

// alarm dismissed
Future<void> onAlarmDismissed(
  DrowsinessAlarmDismissed event,
  Emitter<DrowsinessState> emit,
) async {
  try {
    log('BLoC: Alarm dismissed by user.');
    await alarmFacade.stop();
    lastAlarmDismissedAt = DateTime.now();

    emit(
      state.copyWith(
        alarmActive: false,
        clearError: true,
      ),
    );

    log('BLoC: Alarm dismissed and re-armed.');
  } catch (e, stackTrace) {
    log(
      'BLoC alarm dismissal error: $e',
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