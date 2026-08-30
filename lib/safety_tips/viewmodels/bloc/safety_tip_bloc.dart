import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/safety_tips/repos/safety_tip_repo.dart';
import 'package:sleepy_driver/safety_tips/viewmodels/bloc/safety_tip_event.dart';
import 'package:sleepy_driver/safety_tips/viewmodels/bloc/safety_tip_state.dart';

class SafetyTipBloc
    extends Bloc<
        SafetyTipEvent,
        SafetyTipState> {
  final SafetyTipRepo repository;

  SafetyTipBloc({
    required this.repository,
  }) : super(
          const SafetyTipState(),
        ) {
    on<LoadSafetyTips>(
      loadSafetyTips,
    );
  }

  Future<void> loadSafetyTips(
    LoadSafetyTips event,
    Emitter<SafetyTipState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SafetyTipStatus.loading,
        clearError: true,
      ),
    );

    try {
      await emit.forEach(
        repository.getActiveTips(),
        onData: (tips) {
          return state.copyWith(
            status:
                SafetyTipStatus.loaded,
            tips: tips,
            clearError: true,
          );
        },
        onError: (
          error,
          stackTrace,
        ) {
          log(
            'Safety tips stream error',
            error: error,
            stackTrace: stackTrace,
          );

          return state.copyWith(
            status:
                SafetyTipStatus.error,
            errorMessage:
                'Unable to load safety tips.',
          );
        },
      );
    } catch (e, stackTrace) {
      log(
        'Safety tips error',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status:
              SafetyTipStatus.error,
          errorMessage:
              'Unable to load safety tips.',
        ),
      );
    }
  }
}