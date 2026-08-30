import 'package:cloud_firestore/cloud_firestore.dart';

class DrowsinessAlert {
  final String alertId;
  final String userId;
  final String tripId;
  final DateTime timestamp;
  final String severity;
  final int durationSeconds;
  final double cnnProbability;
  final double? ear;
  final double? mar;
  final bool acknowledged;

  const DrowsinessAlert({
    required this.alertId,
    required this.userId,
    required this.tripId,
    required this.timestamp,
    required this.severity,
    required this.durationSeconds,
    required this.cnnProbability,
    required this.ear,
    required this.mar,
    required this.acknowledged,
  });

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'userId': userId,
      'tripId': tripId,
      'timestamp': Timestamp.fromDate(timestamp),
      'severity': severity,
      'durationSeconds': durationSeconds,
      'cnnProbability': cnnProbability,
      'ear': ear,
      'mar': mar,
      'acknowledged': acknowledged,
    };
  }

  factory DrowsinessAlert.fromMap(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) {
      throw Exception(
        'Drowsiness alert document has no data.',
      );
    }

    return DrowsinessAlert(
      alertId:
          data['alertId']?.toString() ??
              document.id,
      userId:
          data['userId']?.toString() ?? '',
      tripId:
          data['tripId']?.toString() ?? '',
      timestamp:
          _parseTimestamp(data['timestamp']),
      severity:
          data['severity']?.toString() ??
              'normal',
      durationSeconds:
          (data['durationSeconds'] as num?)?.toInt() ??
              0,
      cnnProbability:
          (data['cnnProbability'] as num?)?.toDouble() ??
              0.0,
      ear:
          (data['ear'] as num?)?.toDouble(),
      mar:
          (data['mar'] as num?)?.toDouble(),
      acknowledged:
          data['acknowledged'] == true,
    );
  }

  static DateTime _parseTimestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    throw Exception(
      'Invalid alert timestamp.',
    );
  }
}