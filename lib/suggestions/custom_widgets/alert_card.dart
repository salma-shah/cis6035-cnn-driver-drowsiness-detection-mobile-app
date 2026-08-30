import 'package:flutter/material.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class AlertCard extends StatelessWidget {
  final FatigueSeverity severity;

  const AlertCard({
    super.key,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getSeverityConfig();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: config.borderColor,
            width: 2,
          )
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                config.message,
                style:  TextStyle(
                  color: config.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _SafetyAlertConfig _getSeverityConfig() {
    switch (severity) {
      case FatigueSeverity.mild:
  return const _SafetyAlertConfig(
    backgroundColor: Color(0xFFFFF8D9),
    textColor: Color(0xFF8A6A00),
    borderColor: Color(0xFF8A6A00),
    message:
        'Your alertness is reducing.\nTake a break and get some fresh air.',
  );

case FatigueSeverity.moderate:
  return const _SafetyAlertConfig(
    backgroundColor: Color(0xFFFFEFE3),
    textColor: Color(0xFF9A4F1D),
    borderColor: Color(0xFF9A4F1D),
    message:
        'Your fatigue level is increasing.\nA break is recommended soon.',
  );

case FatigueSeverity.severe:
  return const _SafetyAlertConfig(
    backgroundColor: Color(0xFFE9B0B0),
    borderColor: Color(0xFF9E2929),
    textColor: Color(0xFF9E2929),
    message:
        'Severe fatigue detected.\nPlease stop driving and take a break! It is highly risky to keep driving.',
  );

case FatigueSeverity.normal:
  return const _SafetyAlertConfig(
    backgroundColor: Color(0xFFE9F6EC),
    borderColor: Color(0xFF286A39),
    textColor: Color(0xFF286A39),
    message:
        'You are currently alert.\nDrive safely.',
  );
    }
  }
}

class _SafetyAlertConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final String message;

  const _SafetyAlertConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.message,
    required this.borderColor
  });
}