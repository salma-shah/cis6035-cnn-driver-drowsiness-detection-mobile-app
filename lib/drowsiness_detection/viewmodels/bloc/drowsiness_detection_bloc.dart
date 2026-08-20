import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      
      log(
        'BLoC: Initializing drowsiness detection',
      );

      await repository.initialize();

      final camController = repository.cameraController;
      if (camController == null)
      {
         throw Exception(
    'Camera initialized but CameraController is null.',
  );
}
      emit(
        state.copyWith(
          status: DrowsinessStatus.initializing,
          cameraController: camController,
          clearError: true,
        ),
      );

      emit(
        state.copyWith(
          status: DrowsinessStatus.ready,
          clearError: true,
        ),
      );

      log(
        'BLoC: Drowsiness detection ready.',
      );
    } catch (e) {
      log(
        'BLoC initialization error: $e',
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

      emit(
        state.copyWith(
          status: DrowsinessStatus.monitoring,
          clearError: true,
        ),
      );
      await repository.startMonitoring(
        onPrediction: (double probability) {
          add(
            DrowsinessPredictionReceived(
              probability,
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
    } catch (e) {
      log(
        'BLoC start monitoring error: $e',
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
        isDrowsy: false,
        label: 'Normal',
          clearError: true,
        ),
      );

      log(
        'BLoC: Drowsiness monitoring stopped.',
      );
    } catch (e) {
      log(
        'BLoC stop monitoring error: $e',
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
    final probability = event.probability;

    final isDrowsy = probability > 0.5;

    final label = isDrowsy
        ? 'Drowsy'
        : 'Non Drowsy';

    emit(
      state.copyWith(
        status: DrowsinessStatus.monitoring,
        probability: probability,
        isDrowsy: isDrowsy,
        label: label,
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