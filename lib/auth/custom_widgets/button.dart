import 'package:flutter/material.dart';

class CustomAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomAuthButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: Theme.of(context).elevatedButtonTheme.style,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800
          ),
        ),
      ),
    );
  }
}