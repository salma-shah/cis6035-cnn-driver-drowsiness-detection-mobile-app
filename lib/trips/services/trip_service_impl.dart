import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleepy_driver/trips/models/trip_record.dart';
import 'package:sleepy_driver/trips/services/trip_service.dart';

class TripServiceImpl implements TripServiceInterface {
  final FirebaseFirestore firestore;

  TripServiceImpl({
    FirebaseFirestore? firestore,
  }) : firestore =
            firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _trips =>
          firestore.collection('trips');

  Future<String> createTrip(
    TripRecord trip,
  ) async {
    try {
      final document = _trips.doc();
      final data = trip.toMap();
      // ue Firestore document ID as tripId
      data['tripId'] = document.id;
      await document.set(data);

      log(
        'Trip created: ${document.id}',
        name: 'TripService',
      );

      return document.id;
    } catch (e, stackTrace) {
      log(
        'Failed to create trip',
        name: 'TripService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<void> updateTrip(
    String tripId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _trips.doc(tripId).update(data);

      log(
        'Trip updated: $tripId',
        name: 'TripService',
      );
    } catch (e, stackTrace) {
      log(
        'Failed to update trip',
        name: 'TripService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<TripRecord?> getTrip(
    String tripId,
  ) async {
    try {
      final document =
          await _trips.doc(tripId).get();

      if (!document.exists) {
        return null;
      }

      return TripRecord.fromMap(
        document,
      );
    } catch (e, stackTrace) {
      log(
        'Failed to get trip',
        name: 'TripService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Stream<List<TripRecord>> getUserTrips(
    String userId,
  ) {
    return _trips
        .where(
          'userId',
          isEqualTo: userId,
        )
        .orderBy(
          'startTime',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (document) =>
                      TripRecord.fromMap(
                    document,
                  ),
                )
                .toList();
          },
        );
  }

  Future<void> deleteTrip(
    String tripId,
  ) async {
    try {
      await _trips.doc(tripId).delete();

      log(
        'Trip deleted: $tripId',
        name: 'TripService',
      );
    } catch (e, stackTrace) {
      log(
        'Failed to delete trip',
        name: 'TripService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}