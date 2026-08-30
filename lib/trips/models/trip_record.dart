import 'package:cloud_firestore/cloud_firestore.dart';

class TripRecord {
  final String tripId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final int totalDrowsinessEvents;
  final int totalAlerts;
  final String maxDrowsinessLevel;
  final String status;

  const TripRecord({
    required this.tripId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.totalDrowsinessEvents,
    required this.totalAlerts,
    required this.maxDrowsinessLevel,
    required this.status,
  });

  factory TripRecord.fromMap(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception('Trip data is null');
    }

    return TripRecord(
      tripId: document.id,
      userId: data['userId'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      durationSeconds:
          (data['durationSeconds'] ?? 0) as int,
      totalDrowsinessEvents:
          (data['totalDrowsinessEvents'] ?? 0) as int,
      totalAlerts:
          (data['totalAlerts'] ?? 0) as int,
      maxDrowsinessLevel:
          data['maxDrowsinessLevel'] as String? ?? 'none',
      status:
          data['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime':
          endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationSeconds': durationSeconds,
      'totalDrowsinessEvents': totalDrowsinessEvents,
      'totalAlerts': totalAlerts,
      'maxDrowsinessLevel': maxDrowsinessLevel,
      'status': status,
    };
  }

  TripRecord copyWith({
    String? tripId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? totalDrowsinessEvents,
    int? totalAlerts,
    String? maxDrowsinessLevel,
    String? status,
  }) {
    return TripRecord(
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds:
          durationSeconds ?? this.durationSeconds,
      totalDrowsinessEvents:
          totalDrowsinessEvents ?? this.totalDrowsinessEvents,
      totalAlerts: totalAlerts ?? this.totalAlerts,
      maxDrowsinessLevel:
          maxDrowsinessLevel ?? this.maxDrowsinessLevel,
      status: status ?? this.status,
    );
  }
}