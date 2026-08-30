import 'package:sleepy_driver/breaks/models/break_record.dart';

abstract class BreakServiceInterface {
  Future<String> createBreak(
    BreakRecord breakRecord,
  );

  Future<void> endBreak(
    String breakId, {
    required DateTime endTime,
    required int durationSeconds,
  });

  Future<BreakRecord?> getBreak(
    String breakId,
  );

  Stream<List<BreakRecord>> getTripBreaks(
    String tripId,
  );
}