import 'package:flutter/material.dart';
import 'package:sleepy_driver/styles/app_colours.dart';

class CustomProfileTextField extends StatelessWidget {
  final TextEditingController? controller;
  final bool? readOnly;
  final IconButton? icon;
  final FocusNode? focusNode;

  const CustomProfileTextField({
    this.controller,
    this.readOnly,
    this.icon,
    this.focusNode
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        style: const TextStyle(
          fontSize: 13,
        ),
        textAlign: TextAlign.left,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          suffixIcon: icon,
          filled: true,
          fillColor: AppColours.lightBackground,
          contentPadding: const EdgeInsets.all(12.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
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