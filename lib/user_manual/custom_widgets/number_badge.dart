import 'package:flutter/material.dart';

class NumberBadge extends StatelessWidget {
  final int number;

  const NumberBadge({
    Key? key,
    required this.number,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
       child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}