
import 'package:flutter/material.dart';
import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/styles/app_theme.dart';
import 'package:sleepy_driver/custom_widgets.dart/text_field.dart';
import 'package:sleepy_driver/custom_widgets.dart/button.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SleepyDriver Login Page',
    theme: AppTheme.lightTheme,
    home: LoginPage(),
   );
  }
  
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 150), 
                _buildHeader(context), 
                SizedBox(height: 75),
                _buildBody(context)       
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildHeader(BuildContext context) {
  return Container(
    alignment: Alignment.center,
        child: Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor
          ),
        ),
  );
}

Widget _buildBody(BuildContext context) {
   return Column(
    children: [
      CustomTextField(
        hintText: 'Enter your phone number...',
        prefixIcon: Icons.phone_rounded,
      ),
      const SizedBox(height: 20),
      CustomTextField(
        hintText: 'Enter 6-digit OTP...',
        prefixIcon: Icons.verified_user_rounded,
        obscureText: true,
      ),
      const SizedBox(height: 35),
      CustomButton(text: 
      'Login', onPressed: (){},),
    Row(
      mainAxisAlignment: MainAxisAlignment.values[2],
      children: [
        Text("New to SleepyDriver?"
        , style: TextStyle(fontSize: 16, color: AppColours.lightText),),
        TextButton(onPressed: (){}, child: Text('Sign Up', 
        style: TextStyle(fontSize: 16.5, 
        color: AppColours.lightText, 
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
        decorationThickness: 1.5),))
      ],
    ),
     ],);
   
}