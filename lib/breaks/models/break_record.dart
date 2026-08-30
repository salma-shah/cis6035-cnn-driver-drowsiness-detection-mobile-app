import 'package:cloud_firestore/cloud_firestore.dart';

class BreakRecord {
  final String breakId;
  final String userId;
  final String tripId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
//  final String? stopName;

  const BreakRecord({
    required this.breakId,
    required this.userId,
    required this.tripId,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
  //  required this.stopName,
  });

  Map<String, dynamic> toMap() {
    return {
      'breakId': breakId,
      'userId': userId,
      'tripId': tripId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime == null
          ? null
          : Timestamp.fromDate(endTime!),
      'durationSeconds': durationSeconds,
    //  'stopName': stopName,
    };
  }

  factory BreakRecord.fromMap(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return BreakRecord(
      breakId:
          data['breakId'] ?? document.id,
      userId:
          data['userId'] ?? '',
      tripId:
          data['tripId'] ?? '',
      startTime:
          (data['startTime'] as Timestamp).toDate(),
      endTime:
          data['endTime'] == null
              ? null
              : (data['endTime'] as Timestamp).toDate(),
      durationSeconds:
          data['durationSeconds'] ?? 0,
    //  stopName:
       //     data['stopName'],
    );
  }
}