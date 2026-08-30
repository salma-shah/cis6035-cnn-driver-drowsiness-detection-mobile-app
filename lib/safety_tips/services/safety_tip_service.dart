import '../models/safety_tip.dart';

abstract interface class SafetyTipServiceInterface {
  Stream<List<SafetyTip>> getActiveTips();

  Future<String> createTip(
    SafetyTip tip,
  );
}