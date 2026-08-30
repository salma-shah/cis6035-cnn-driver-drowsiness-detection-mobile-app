import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';

class FatigueLevelLabel extends StatelessWidget {
  final FatigueSeverity fatigueSeverity;
  final double? probability;

  const FatigueLevelLabel({
    super.key,
    required this.fatigueSeverity,
    this.probability,
  });

  @override
  Widget build(BuildContext context) {
    Color lblBgColor;
    Color txtColor;
    Color borderColor;
    String text;

    switch (fatigueSeverity) {
      case FatigueSeverity.normal:
        lblBgColor = const Color(0xFF74DB8E);
        txtColor = const Color(0xFF00FF40);
        borderColor = const Color(0xFF00FF40);
        text = 'Active';
        break;

      case FatigueSeverity.mild:
        lblBgColor = const Color(0xFFFCFF48);
        txtColor = const Color(0xFFFBFF00);
        borderColor = const Color(0xFFFBFF00);
        text = 'Mild';
        break;

      case FatigueSeverity.moderate:
        lblBgColor = const Color(0xFFF68E34);
        txtColor = const Color(0xFFFF5E00);
        borderColor = const Color(0xFFFF5E00);
        text = 'Moderate';
        break;

      case FatigueSeverity.severe:
        lblBgColor = const Color(0xFFFF2A2E);
        txtColor = Color(0xFFFF0004);
        borderColor = const Color(0xFFFF0004);
        text = 'Extreme';
        break;
    }

    final probabilityText = probability != null
        ? ' ${(probability! * 100).toStringAsFixed(0)}%'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: lblBgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$text$probabilityText',
            style: TextStyle(
              color: txtColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}