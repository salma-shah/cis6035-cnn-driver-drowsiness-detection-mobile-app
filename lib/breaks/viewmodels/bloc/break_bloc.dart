import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/breaks/models/break_record.dart';
import 'package:sleepy_driver/breaks/repos/break_repo.dart';

import 'break_event.dart';
import 'break_state.dart';

class BreakBloc extends Bloc<BreakEvent, BreakState> {
  final BreakRepo repository;

  BreakBloc({
    required this.repository,
  }) : super(const BreakState()) {
    on<StartBreak>(onStartBreak);
    on<EndBreak>(onEndBreak);
  }

 // starting a break
  Future<void> onStartBreak(
    StartBreak event,
    Emitter<BreakState> emit,
  ) async {
    try {
      // if one break is already ongoing, cant start another one
      if (state.status == BreakStatus.active) {
        return;
      }

      final startTime = DateTime.now();
      final breakRecord = BreakRecord(
        breakId: '',
        userId: '',
        tripId: event.tripId,
        startTime: startTime,
        endTime: null,
        durationSeconds: 0,
      );

      final breakId =
          await repository.createBreak(
        breakRecord,
      );

      emit(
        state.copyWith(
          status: BreakStatus.active,
          breakId: breakId,
          startTime: startTime,
          errorMessage: null,
        ),
      );

      log(
        'Break started: $breakId',
      );
    } catch (e, stackTrace) {
      log(
        'Start break error',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: BreakStatus.error,
          errorMessage:
              'Unable to start break.',
        ),
      );
    }
  }

  // end a break
  Future<void> onEndBreak(
    EndBreak event,
    Emitter<BreakState> emit,
  ) async {
    try {
      final breakId = state.breakId;
      final startTime = state.startTime;

      if (breakId == null ||
          startTime == null) {
        return;
      }

      final endTime = DateTime.now();

      final duration =
          endTime.difference(startTime);

      await repository.endBreak(
        breakId,
        endTime: endTime,
        durationSeconds:
            duration.inSeconds,
      );

      emit(
        state.copyWith(
          status: BreakStatus.completed,
          clearBreak: true,
        ),
      );

      log(
        'Break ended: $breakId',
      );
    } catch (e, stackTrace) {
      log(
        'End break error',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: BreakStatus.error,
          errorMessage:
              'Unable to end break.',
        ),
      );
    }
  }
}