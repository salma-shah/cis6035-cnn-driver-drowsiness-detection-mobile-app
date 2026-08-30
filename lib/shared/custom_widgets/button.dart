import 'package:flutter/material.dart';

class CustomGeneralButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? bgColor;
  final Color? txtColor;
  final Color? borderColor;

  const CustomGeneralButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.txtColor,
    this.bgColor,
    this.borderColor
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
          ? WidgetStatePropertyAll(txtColor) : null,
          side: borderColor != null ?
          WidgetStatePropertyAll(BorderSide(color: borderColor!)) : null,
        )
        ,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}