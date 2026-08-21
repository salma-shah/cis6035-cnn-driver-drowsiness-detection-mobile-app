import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sleepy_driver/drowsiness_detection/models/drowsiness_result.dart';
import 'package:sleepy_driver/drowsiness_detection/repos/drowsiness_detection_repo.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_event.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_state.dart';

class DrowsinessBloc
    extends Bloc<DrowsinessEvent, DrowsinessState> {

  final DrowsinessDetectionRepo repository;

  DrowsinessBloc({
    required this.repository,
  }) : super(
          const DrowsinessState(),
        ) {

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
  }

  Future<void> onInitialize(
    DrowsinessInitialize event,
    Emitter<DrowsinessState> emit,
  ) async {

    try {
      emit(state.copyWith(status: DrowsinessStatus.initializing,clearError: true));
      await repository.initialize();
      final camController = repository.cameraController;
      if (camController == null) { throw Exception('Camera initialized but CameraController is null.');
      }

      emit(
        state.copyWith(
          status: DrowsinessStatus.ready,
          cameraController: camController,
          clearError: true,
        ),
      );

      log('BLoC: Drowsiness detection ready.',);

    } catch (e, stackTrace) {

      log('BLoC initialization error: $e', stackTrace: stackTrace);

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

      emit(
        state.copyWith(
          status: DrowsinessStatus.monitoring,
          clearError: true,
        ),
      );

      await repository.startMonitoring(
        onPrediction: (
          DrowsinessResult result,
        ) {
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

      emit(
        state.copyWith(
          status: DrowsinessStatus.stopped,
          probability: 0.0,
          ear: null,
          mar: null,
          isDrowsy: false,
          label: 'Normal',
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

  void onPredictionReceived(
    DrowsinessPredictionReceived event,
    Emitter<DrowsinessState> emit,
  ) {

    final result = event.result;

    emit(
      state.copyWith(
        status: DrowsinessStatus.monitoring,
        probability:result.probability,   // passes the relevant results
        ear:result.ear, 
        mar: result.mar,
        isDrowsy: result.isDrowsy,
        label:result.label,   // and drowsy / non drowsy label
        severity: result.severity,
        clearError: true,
      ),
    );
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
    await repository.dispose();
    return super.close();
  }
}