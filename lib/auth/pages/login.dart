
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/routing/route_constants.dart';
import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/styles/app_theme.dart';
import 'package:sleepy_driver/auth/custom_widgets/text_field.dart';
import 'package:sleepy_driver/auth/custom_widgets/button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/auth/viewmodels/bloc/auth_bloc.dart';
import 'package:sleepy_driver/auth/custom_widgets/toast.dart';

// login page with phone and otp fields
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  bool otpSent = false;
  bool isLoading = false;
  String verificationId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpCodeSentState) {
            setState(() {
              otpSent = true;
              verificationId = state.verificationId;
            });
            log("OTP WAS SENT to ${phoneController.text}");
            CustomToast.show(
              context: context,
              message: 'OTP was sent to ${phoneController.text}',
              icon: Icons.sms_outlined,
              bgColor: AppColours.success,
            );
          }
          
          // if error
          if (state is AuthErrorState) {
            CustomToast.show(
              context: context,
              message: state.errorMessage,
              icon: Icons.error_outline,
              bgColor: AppColours.error,
            );
          }

          // if successfully verified
          if (state is AuthSuccessState) {
            CustomToast.show(
              context: context,
              message: 'Welcome back, ${state.user.name}!',
              icon: Icons.check_circle_outline,
              bgColor: AppColours.success,
              );
              context.pushNamed(RouteConstants.home);
          } 
        },

        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Padding(
        padding: const EdgeInsets.all(30.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 150), 
                  _buildHeader(context), 
                  SizedBox(height: 65),
                  _buildBody(context)       
              ],
            ),
          ),
        ),);
          },
        )
    )
    );
  }

Widget _buildHeader(BuildContext context) {
  return Container(
    alignment: Alignment.center,
        child: Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor
          ),
        ),
  );
}

Widget _buildBody(BuildContext context) {
   return Column(
    children: [
      CustomAuthTextField(
        controller: phoneController,
        hintText: '+1-234-567-8900',
        prefixIcon: Icons.phone_rounded,
        autovalidateMode: AutovalidateMode.disabled,
        validator: (value) {
          if (value == null || value.toString().trim().isEmpty) {
            return 'Please enter your phone number';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      if (otpSent)
          CustomAuthTextField(
            controller: otpController,
            hintText: 'Enter 6-digit OTP...',
            prefixIcon: Icons.verified_user_rounded,
            autovalidateMode: AutovalidateMode.disabled,
            validator: (value) {
          if (value == null || value.toString().trim().isEmpty) {
            return 'Please enter the OTP';
          }
          return null;
        },
          ),
      const SizedBox(height: 35),
      CustomAuthButton(
        text: otpSent ? 'Verify OTP' : 'Login',
        onPressed: (){
          if (!otpSent) {
            // trigger event to send OTP
            context.read<AuthBloc>().add(OtpSentEvent(phoneNumber: phoneController.text, isSignUp: false));
          } else {
            // trigger event to verify OTP
            context.read<AuthBloc>().add(OtpVerifiedEvent(
              verificationId: verificationId,
              otp: otpController.text.trim(), name: ''
            ));

            log('verificationId: $verificationId, otp: ${otpController.text}');
          }
        },
      ),
    Row(
      mainAxisAlignment: MainAxisAlignment.values[2],
      children: [
        Text("New to SleepyDriver?"
        , style: TextStyle(fontSize: 14, color: AppColours.lightText),),
        TextButton(onPressed: (){
          context.pushNamed(RouteConstants.signUp);
        }, child: Text('Sign Up', 
        style: TextStyle(fontSize: 14.5, 
        color: AppColours.lightText, 
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
        decorationThickness: 1.5),))
      ],
    ),
     ],);
   
}
}