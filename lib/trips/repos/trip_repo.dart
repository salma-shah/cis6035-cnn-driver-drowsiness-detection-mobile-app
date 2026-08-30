import 'package:firebase_auth/firebase_auth.dart';

import 'package:sleepy_driver/trips/models/trip_record.dart';
import 'package:sleepy_driver/trips/services/trip_service.dart';
import 'package:sleepy_driver/trips/services/trip_service_impl.dart';

class TripRepository {
  final TripServiceInterface tripService;
  final FirebaseAuth firebaseAuth;

  TripRepository({
    TripServiceInterface? tripService,
    FirebaseAuth? firebaseAuth,
  })  : tripService =
            tripService ?? TripServiceImpl(),
        firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance;

  User get _currentUser {
    final user =
        firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    return user;
  }

  // create a trip record
  Future<String> createTrip({
    required DateTime startTime,
  }) {
    final user = _currentUser;

    final trip = TripRecord(
      tripId: '',
      userId: user.uid,
      startTime: startTime,
      endTime: null,
      durationSeconds: 0,
      totalDrowsinessEvents: 0,
      totalAlerts: 0,
      maxDrowsinessLevel: 'none',
      status: 'active',
    );

    return tripService.createTrip(
      trip,
    );
  }

  Future<void> completeTrip({
    required String tripId,
    required DateTime startTime,
    required int totalDrowsinessEvents,
    required int totalAlerts,
    required String maxDrowsinessLevel,
  }) async {
    final user = _currentUser;

    final endTime =
        DateTime.now();

    final durationSeconds =
        endTime
            .difference(startTime)
            .inSeconds;

    await tripService.updateTrip(
      tripId,
      {
        'userId': user.uid,
        'endTime': endTime,
        'durationSeconds':
            durationSeconds,
        'totalDrowsinessEvents':
            totalDrowsinessEvents,
        'totalAlerts':
            totalAlerts,
        'maxDrowsinessLevel':
            maxDrowsinessLevel,
        'status': 'completed',
      },
    );
  }

  Future<TripRecord?> getTrip(
    String tripId,
  ) {
    return tripService.getTrip(
      tripId,
    );
  }

  Stream<List<TripRecord>> getMyTrips() {
    return tripService.getUserTrips(
      _currentUser.uid,
    );
  }

  Future<void> deleteTrip(
    String tripId,
  ) {
    return tripService.deleteTrip(
      tripId,
    );
  }
}