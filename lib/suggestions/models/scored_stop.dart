import 'package:sleepy_driver/suggestions/models/rest_stop.dart';

class ScoredStop {
  final RestStop stop;
  final double score;

  const ScoredStop({
    required this.stop,
    required this.score,
  });
}