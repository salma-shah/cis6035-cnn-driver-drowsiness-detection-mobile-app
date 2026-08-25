import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/break_record.dart';

class BreakService {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  BreakService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : firestore =
            firestore ?? FirebaseFirestore.instance,
        firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _breaks =>
      firestore.collection('breaks');

  Future<String> createBreak(
    BreakRecord breakRecord,
  ) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    try {
      final document = _breaks.doc();

      final data = breakRecord.toMap();

      // use authenticated user's ID
      data['userId'] = user.uid;
      data['breakId'] = document.id;  // firestore generates ids automatically

      await document.set(data);

      log(
        'Break created: ${document.id}',
        name: 'BreakService',
      );

      return document.id;
    } catch (e, stackTrace) {
      log(
        'Failed to create break.',
        name: 'BreakService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<void> endBreak(
    String breakId, {
    required DateTime endTime,
    required int durationSeconds,
  }) async {
    try {
      await _breaks.doc(breakId).update({
        'endTime': Timestamp.fromDate(endTime),
        'durationSeconds': durationSeconds,
      });

      log(
        'Break ended: $breakId',
        name: 'BreakService',
      );
    } catch (e, stackTrace) {
      log(
        'Failed to end break.',
        name: 'BreakService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<BreakRecord?> getBreak(
    String breakId,
  ) async {
    try {
      final document =
          await _breaks.doc(breakId).get();

      if (!document.exists) {
        return null;
      }

      return BreakRecord.fromMap(document);
    } catch (e, stackTrace) {
      log(
        'Failed to get break.',
        name: 'BreakService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Stream<List<BreakRecord>> getTripBreaks(
    String tripId,
  ) {
    return _breaks
        .where(
          'tripId',
          isEqualTo: tripId,
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
                      BreakRecord.fromMap(document),
                )
                .toList();
          },
        );
  }
}