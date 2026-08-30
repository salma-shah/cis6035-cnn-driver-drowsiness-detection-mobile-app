import 'package:flutter/widgets.dart';

class StatusDot extends StatelessWidget {
  final Color color;

  const StatusDot({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}