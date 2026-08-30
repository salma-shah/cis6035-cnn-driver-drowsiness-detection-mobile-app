import 'package:sleepy_driver/breaks/services/break_service.dart';

import '../models/break_record.dart';

class BreakRepo {
  final BreakServiceInterface service;

  BreakRepo({
    required this.service,
  });

  Future<String> createBreak(
    BreakRecord breakRecord,
  ) {
    return service.createBreak(
      breakRecord,
    );
  }

  Future<void> endBreak(
    String breakId, {
    required DateTime endTime,
    required int durationSeconds,
  }) {
    return service.endBreak(
      breakId,
      endTime: endTime,
      durationSeconds: durationSeconds,
    );
  }

  Future<BreakRecord?> getBreak(
    String breakId,
  ) {
    return service.getBreak(
      breakId,
    );
  }

  Stream<List<BreakRecord>> getTripBreaks(
    String tripId,
  ) {
    return service.getTripBreaks(
      tripId,
    );
  }
}