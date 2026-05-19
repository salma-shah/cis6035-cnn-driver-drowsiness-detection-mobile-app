import 'package:flutter/material.dart';
import 'package:sleepy_driver/styles/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SleepyDriver Landing Page',
    theme: AppTheme.lightTheme,
    home: LandingPage(),
   );
  }
  
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 100), 
              _buildHeader(context), 
              _buildBody()       
          ],
        ),
      ),
    );
  }
}

Widget _buildHeader(BuildContext context) {
  return Container(
    alignment: Alignment.center,
        child: Text(
          'SleepyDriver',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            color: Theme.of(context).primaryColor
          ),
        ),
  );
}

Widget _buildBody() {
   return Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child:
              Image.asset('assets/images/img_landing_pg.jpg', 
              width: double.infinity, fit: BoxFit.cover),    
          ),
        );
}