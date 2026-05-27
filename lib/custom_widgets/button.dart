import 'package:flutter/material.dart';

class CustomGeneralButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? bgColor;
  final Color? txtColor;

  const CustomGeneralButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.txtColor,
    this.bgColor
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
          backgroundColor: bgColor != null
          ? WidgetStatePropertyAll(bgColor) : null,
          foregroundColor: txtColor != null 
          ? WidgetStatePropertyAll(txtColor) : null
        )
        ,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}