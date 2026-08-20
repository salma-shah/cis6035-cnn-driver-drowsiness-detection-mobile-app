import 'package:flutter/material.dart';
import 'package:sleepy_driver/dashboard/fatigue_severity.dart';

class FatigueLevelLabel extends StatelessWidget 
{
  final FatigueSeverity fatigueSeverity;
  const FatigueLevelLabel({super.key, required this.fatigueSeverity});

  @override
  Widget build(BuildContext context) {
    Color lblBgColor, txtColor, borderColor;
    String text;

// what to display based on severity
switch (fatigueSeverity) {
  case FatigueSeverity.normal:
    lblBgColor = Color(0xFF74DB8E);
    txtColor = Color(0xFF00FF40); 
    borderColor = Color(0xFF00FF40);
    text = "Active";
    break;
    case FatigueSeverity.mild:
    lblBgColor = Color(0xFFFCFF48);
    txtColor = Color(0xFFFBFF00); 
    borderColor = Color(0xFFFBFF00);
    text = "Drowsy";
    break;
    case FatigueSeverity.moderate:
    lblBgColor = Color(0xFFF68E34);
    txtColor = Color(0xFFFF5E00); 
    borderColor = Color(0xFFFF5E00);
    text = "Moderate";
    break;
    case FatigueSeverity.severe:
    lblBgColor = Color(0xFFFF2A2E);
    txtColor = Color(0xFFFF0004);; 
    borderColor = Color(0xFFFF0004);
    text = "Extreme";
    break;
}

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: lblBgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha:0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: txtColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }}