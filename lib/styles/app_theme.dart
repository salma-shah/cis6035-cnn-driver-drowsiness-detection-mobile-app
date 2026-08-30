import 'package:flutter/material.dart';
import 'app_colours.dart';

class AppTheme
{
  // light theme for now, can add dark theme later
  static ThemeData lightTheme = ThemeData(
  fontFamily: 'Montserrat',

   brightness: Brightness.light,
   colorScheme: ColorScheme.light(
   primary: AppColours.primary, 
   onPrimary: AppColours.lightText,
   secondary: AppColours.secondary,
   tertiary: AppColours.fill,
   error: AppColours.error
  ),

  scaffoldBackgroundColor: AppColours.lightBackground,

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColours.primary,
      foregroundColor: AppColours.lightButtonText,
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily:'Montserrat'),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      side: const BorderSide(color: AppColours.primary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
       
      ),
    ),
  ),
  
  );

  // Define dark theme if needed
}
