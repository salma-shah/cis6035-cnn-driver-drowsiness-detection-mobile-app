import 'package:equatable/equatable.dart';

import 'package:sleepy_driver/trips/models/trip_record.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}


class StartTripEvent extends TripEvent {
  final DateTime startTime;

  const StartTripEvent({
    required this.startTime,
  });

  @override
  List<Object?> get props => [
        startTime,
      ];
}


class CompleteTripEvent extends TripEvent {
  final String tripId;
  final DateTime startTime;
 // final double distanceKm;
  final int totalDrowsinessEvents;
  final int totalAlerts;
  final String maxDrowsinessLevel;

  const CompleteTripEvent({
    required this.tripId,
    required this.startTime,
   // required this.distanceKm,
    required this.totalDrowsinessEvents,
    required this.totalAlerts,
    required this.maxDrowsinessLevel,
  });

  @override
  List<Object?> get props => [
        tripId,
        startTime,
     //   distanceKm,
        totalDrowsinessEvents,
        totalAlerts,
        maxDrowsinessLevel,
      ];
}


class LoadMyTripsEvent extends TripEvent {
  const LoadMyTripsEvent();
}

class DeleteTripEvent extends TripEvent {
  final String tripId;

  const DeleteTripEvent({
    required this.tripId,
  });

  @override
  List<Object?> get props => [
        tripId,
      ];
}

class TripsUpdatedEvent extends TripEvent {
  final List<TripRecord> trips;

  const TripsUpdatedEvent(
    this.trips,
  );

  @override
  List<Object?> get props => [
        trips,
      ];
}


class TripsErrorEvent extends TripEvent {
  final String message;

  const TripsErrorEvent(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}