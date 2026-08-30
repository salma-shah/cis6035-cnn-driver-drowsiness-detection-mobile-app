import 'package:sleepy_driver/safety_tips/services/safety_tip_service.dart';

import '../models/safety_tip.dart';

class SafetyTipRepo {
  final SafetyTipServiceInterface service;

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