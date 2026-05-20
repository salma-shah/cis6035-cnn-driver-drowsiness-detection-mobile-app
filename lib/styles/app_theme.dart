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
   secondary: AppColours.secondary
  ),

  scaffoldBackgroundColor: AppColours.lightBackground,

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColours.primary,
      foregroundColor: AppColours.lightButtonText,
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  ),
  
  );

  // Define dark theme if needed
}
