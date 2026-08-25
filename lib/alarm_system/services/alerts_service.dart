import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/drowsiness_alert.dart';

class DrowsinessAlertService {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  DrowsinessAlertService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : firestore =
            firestore ?? FirebaseFirestore.instance,
        firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get _alerts =>
          firestore.collection(
            'drowsiness_alerts',
          );

  // add an alert record for the user

  Future<String> createAlert(
    DrowsinessAlert alert,
  ) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    try {
      final document = _alerts.doc();
      final data = alert.toMap();

      data['userId'] = user.uid;
      data['alertId'] = document.id;

      await document.set(data);

      log(
        'Drowsiness alert created: ${document.id}',
        name: 'DrowsinessAlertService',
      );

      return document.id;
    } catch (e, stackTrace) {
      log(
        'Failed to create drowsiness alert.',
        name: 'DrowsinessAlertService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<DrowsinessAlert?> getAlert(
    String alertId,
  ) async {
    try {
      final document =
          await _alerts.doc(alertId).get();

      if (!document.exists) {
        return null;
      }

      return DrowsinessAlert.fromMap(
        document,
      );
    } catch (e, stackTrace) {
      log(
        'Failed to get alert.',
        name: 'DrowsinessAlertService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Stream<List<DrowsinessAlert>>
      getTripAlerts(
    String tripId,
  ) {
    return _alerts
        .where(
          'tripId',
          isEqualTo: tripId,
        )
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (document) =>
                      DrowsinessAlert.fromMap(
                    document,
                  ),
                )
                .toList();
          },
        );
  }

  Stream<List<DrowsinessAlert>>
      getCurrentUserAlerts() {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    return _alerts
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (document) =>
                      DrowsinessAlert.fromMap(
                    document,
                  ),
                )
                .toList();
          },
        );
  }


  Future<void> acknowledgeAlert(
    String alertId,
  ) async {
    try {
      await _alerts
          .doc(alertId)
          .update({
        'acknowledged': true,
      });

      log(
        'Alert acknowledged: $alertId',
        name: 'DrowsinessAlertService',
      );
    } catch (e, stackTrace) {
      log(
        'Failed to acknowledge alert.',
        name: 'DrowsinessAlertService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}