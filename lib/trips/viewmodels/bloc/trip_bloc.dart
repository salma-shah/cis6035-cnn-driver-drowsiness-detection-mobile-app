import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sleepy_driver/trips/models/trip_record.dart';
import 'package:sleepy_driver/trips/repos/trip_repo.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_event.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_state.dart';

class TripBloc
    extends Bloc<TripEvent, TripState> {
  final TripRepository tripRepository;

  StreamSubscription<List<TripRecord>>?
      tripsSubscription;

  TripBloc({
    required this.tripRepository,
  }) : super(
          const TripInitial(),
        ) 
        
  {
    on<StartTripEvent>(
      onStartTrip,
    );

    on<CompleteTripEvent>(
      onCompleteTrip,
    );

    on<LoadMyTripsEvent>(
      onLoadMyTrips,
    );

    on<DeleteTripEvent>(
      onDeleteTrip,
    );

    on<TripsUpdatedEvent>(
      onTripsUpdated,
    );

    on<TripsErrorEvent>(
      onTripsError,
    );
  }
  Future<void> onStartTrip(
    StartTripEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(
      const TripLoading(),
    );

    try {
      final tripId =
          await tripRepository.createTrip(
        startTime: event.startTime,
      );

      emit(
        TripStarted(
          tripId: tripId,
          startTime: event.startTime,
        ),
      );
    } catch (e, stackTrace) {
      log(
        'Failed to start trip.',
        name: 'TripBloc',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        TripError(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> onCompleteTrip(
    CompleteTripEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(
      const TripLoading(),
    );

    try {
      await tripRepository.completeTrip(
        tripId: event.tripId,
        startTime: event.startTime,
        totalDrowsinessEvents:
            event.totalDrowsinessEvents,
        totalAlerts:
            event.totalAlerts,
        maxDrowsinessLevel:
            event.maxDrowsinessLevel,
      );

      emit(
        const TripCompleted(),
      );
    } catch (e, stackTrace) {
      log(
        'Failed to complete trip.',
        name: 'TripBloc',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        TripError(
          message: e.toString(),
        ),
      );
    }
  }

  //load user trips to display
  Future<void> onLoadMyTrips(
    LoadMyTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(
      const TripLoading(),
    );

    await tripsSubscription?.cancel();
    tripsSubscription = null;

    try {
      final stream =
          tripRepository.getMyTrips();

      tripsSubscription =
          stream.listen(
        (trips) {
          add(
            TripsUpdatedEvent(
              trips,
            ),
          );
        },
        onError: (error) {
          add(
            TripsErrorEvent(
              error.toString(),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      log(
        'Failed to load user trips.',
        name: 'TripBloc',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        TripError(
          message: e.toString(),
        ),
      );
    }
  }

  void onTripsUpdated(
    TripsUpdatedEvent event,
    Emitter<TripState> emit,
  ) {
    emit(
      TripsLoaded(
        trips: event.trips,
      ),
    );
  }

  void onTripsError(
    TripsErrorEvent event,
    Emitter<TripState> emit,
  ) {
    log(
      'Trip stream error: ${event.message}',
      name: 'TripBloc',
    );

    emit(
      TripError(
        message: event.message,
      ),
    );
  }

  Future<void> onDeleteTrip(
    DeleteTripEvent event,
    Emitter<TripState> emit,
  ) async {
    try {
      await tripRepository.deleteTrip(
        event.tripId,
      );
    } catch (e, stackTrace) {
      log(
        'Failed to delete trip.',
        name: 'TripBloc',
        error: e,
        stackTrace: stackTrace,
      );

      emit(
        TripError(
          message: e.toString(),
        ),
      );
    }
  }


  @override
  Future<void> close() async {
    await tripsSubscription?.cancel();
    return super.close();
  }
}