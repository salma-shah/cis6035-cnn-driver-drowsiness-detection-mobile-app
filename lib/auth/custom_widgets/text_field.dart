import 'package:flutter/material.dart';
import 'package:sleepy_driver/styles/app_colours.dart';

class CustomAuthTextField extends StatelessWidget {

  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final AutovalidateMode autovalidateMode;
   final FormFieldValidator<String>? validator;

  const CustomAuthTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    required this.autovalidateMode,
    required this.validator
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: TextFormField(
        style: const TextStyle(
          fontSize: 14,
        ),
        controller: controller,
        validator: validator,
        autovalidateMode:  autovalidateMode,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
      
          filled: true,
          fillColor: AppColours.lightBackground,
      
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
      
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColours.lightText,
              width: 1.5,
            ),
          ),
      
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppColours.fill,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}