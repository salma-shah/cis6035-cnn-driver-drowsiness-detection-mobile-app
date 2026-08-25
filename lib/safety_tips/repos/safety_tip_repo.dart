import '../models/safety_tip.dart';
import '../services/safety_tip_service.dart';

class SafetyTipRepo {
  final SafetyTipService service;

  SafetyTipRepo({
    required this.service,
  });

  Stream<List<SafetyTip>> getActiveTips() {
    return service.getActiveTips();
  }

  Future<String> createTip(
    SafetyTip tip,
  ) {
    return service.createTip(tip);
  }
}