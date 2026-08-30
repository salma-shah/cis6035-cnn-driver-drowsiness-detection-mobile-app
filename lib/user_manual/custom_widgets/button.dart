import 'package:flutter/material.dart';

class CustomUserManualButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomUserManualButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ))
        ),
        child: FittedBox(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w900
            ),
          ),
        ),
        
      ),
    );
  }
}