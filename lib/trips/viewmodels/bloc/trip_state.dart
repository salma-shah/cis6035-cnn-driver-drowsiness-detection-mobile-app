import 'package:equatable/equatable.dart';

import 'package:sleepy_driver/trips/models/trip_record.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}


class TripInitial extends TripState {
  const TripInitial();
}


class TripLoading extends TripState {
  const TripLoading();
}


class TripStarted extends TripState {
  final String tripId;
  final DateTime startTime;

  const TripStarted({
    required this.tripId,
    required this.startTime,
  });

  @override
  List<Object?> get props => [
        tripId,
        startTime,
      ];
}

class TripCompleted extends TripState {
  const TripCompleted();
}

class TripsLoaded extends TripState {
  final List<TripRecord> trips;

  const TripsLoaded({
    required this.trips,
  });

  @override
  List<Object?> get props => [
        trips,
      ];
}

class TripError extends TripState {
  final String message;

  const TripError({
    required this.message,
  });

  @override
  List<Object?> get props => [
        message,
      ];
}