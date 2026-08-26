import 'package:sleepy_driver/trips/models/trip_record.dart';

abstract class TripServiceInterface {
  Future<String> createTrip(TripRecord trip);
  Future<void> updateTrip(
    String tripId,
    Map<String, dynamic> data,
  );
  Future<TripRecord?> getTrip(String tripId);
  Stream<List<TripRecord>> getUserTrips(String userId);
  Future<void> deleteTrip(String tripId);
}