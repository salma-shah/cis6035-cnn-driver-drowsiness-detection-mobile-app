import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleepy_driver/safety_tips/models/safety_tip.dart';
import 'package:sleepy_driver/safety_tips/services/safety_tip_service.dart';

class SafetyTipServiceImpl implements SafetyTipServiceInterface {
  final FirebaseFirestore firestore;

  SafetyTipServiceImpl({
    FirebaseFirestore? firestore,
  }) : firestore =
            firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _tips =>
          firestore.collection('safety_tips');

  Future<String> createTip(
    SafetyTip tip,
  ) async {
    try {
      final document = _tips.doc();

      final data = tip.toMap();

      data['tipId'] = document.id;

      await document.set(data);

      log(
        'Safety tip created: ${document.id}',
        name: 'SafetyTipService',
      );

      return document.id;
    } catch (e, stackTrace) {
      log(
        'Failed to create safety tip.',
        name: 'SafetyTipService',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Stream<List<SafetyTip>> getActiveTips() {
    return _tips
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (document) =>
                      SafetyTip.fromMap(
                    document,
                  ),
                )
                .toList();
          },
        );
  }
}