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
    home: SignUpPage(),
   );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SafeArea(
          child: SingleChildScrollView(
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
      ),
    );
  }
}

Widget _buildHeader(BuildContext context) {
  return Container(
    alignment: Alignment.center,
        child: Text(
          'Welcome!',
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
        hintText: 'Enter your name...', 
        prefixIcon: Icons.person),
      SizedBox(height: 20),
      CustomTextField(
        hintText: 'Enter your phone number...',
        prefixIcon: Icons.phone_rounded,
      ),
      SizedBox(height: 20),
      CustomTextField(
        hintText: 'Enter 6-digit OTP...',
        prefixIcon: Icons.verified_user_rounded,
        obscureText: true,
      ),
      SizedBox(height: 20),
      CustomButton(
        text: 'Sign Up',
        onPressed: () {
          // Handle sign up logic heres
        },
      ),
       Row(
      mainAxisAlignment: MainAxisAlignment.values[2],
      children: [
        Text("Have an account?"
        , style: TextStyle(fontSize: 16, color: AppColours.lightText),),
        TextButton(onPressed: (){}, child: Text('Login', 
        style: TextStyle(fontSize: 16.5, 
        color: AppColours.lightText, 
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
        decorationThickness: 1.5),))
      ],
    ),
    ],
  );
}
  