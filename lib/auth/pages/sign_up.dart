import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/routing/route_constants.dart';
import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/auth/custom_widgets/text_field.dart';
import 'package:sleepy_driver/shared/custom_widgets/button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/auth/viewmodels/bloc/auth_bloc.dart';
import 'package:sleepy_driver/auth/custom_widgets/toast.dart';

// sign up page with phone number, name, and OTP fields
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
   final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  // final formKey = GlobalKey<Form>;

  bool otpSent = false;
  bool isLoading = false;
  String verificationId = '';
  Map<String, String> params = const <String ,String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {   

        if (state is OtpCodeSentState) {
            setState(() {
              otpSent = true;
              verificationId = state.verificationId;
            });

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
              message: 'Welcome, ${nameController.text}!',
              icon: Icons.check_circle_outline,
              bgColor: AppColours.success,
            );
            if (mounted)
            {
              context.goNamed(RouteConstants.home);
            }
            // else 
            // {
            //   CustomToast.show(
            //   context: context,
            //   message: 'Something went wrong, we apologize!',
            //   icon: Icons.error_outline,
            //   bgColor: AppColours.error,
            // );
            }
          
        },
          builder: (context, state) {
            final isLoading = state is AuthLoadingState;

           return Stack(
             children: 
             [ 
              Padding(
              padding: const EdgeInsets.all(30.0),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 150),
                      _buildHeader(context),
                      SizedBox(height: 65),
                      _buildBody(context),
                    ],
                ),
              ),
                       )),

                       // loading indicator
                       if (isLoading)
        Container(
          color: Colors.black26,
          child: Center(
            child:
                CircularProgressIndicator(),
          ),
        ),
             ]
           );
          },
            ));
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Welcome!',
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
Widget _buildBody(BuildContext context) {
  return Form(
    key: _formKey,
    child: Column(
      children: [
        CustomAuthTextField(
          controller: nameController,
          hintText: 'Enter your name...',
          prefixIcon: Icons.person_rounded,
          autovalidateMode:
              AutovalidateMode.disabled,
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter your name';
            }

            return null;
          },
        ),

        const SizedBox(height: 20),

        CustomAuthTextField(
          controller: phoneController,
          hintText: '+94 71 234 5678',
          prefixIcon: Icons.phone_rounded,
          autovalidateMode:
              AutovalidateMode.disabled,
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter the phone number';
            }

            final phone =
                value.trim().replaceAll(' ', '');

            final sriLankanPhoneRegex =
                RegExp(r'^(?:\+94|0)7\d{8}$');

            if (!sriLankanPhoneRegex
                .hasMatch(phone)) {
              return 'Enter a valid Sri Lankan phone number';
            }

            return null;
          },
        ),

        const SizedBox(height: 20),

        if (otpSent)
          CustomAuthTextField(
            controller: otpController,
            hintText: 'Enter 6-digit OTP...',
            prefixIcon:
                Icons.verified_user_rounded,
            autovalidateMode:
                AutovalidateMode.disabled,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter the OTP';
              }

              if (!RegExp(r'^\d{6}$')
                  .hasMatch(value.trim())) {
                return 'Enter a valid 6-digit OTP';
              }

              return null;
            },
          ),

        const SizedBox(height: 20),

        CustomGeneralButton(
          text: otpSent
              ? 'Verify OTP'
              : 'Sign Up',
          onPressed: () {
            final isValid =
                _formKey.currentState!
                    .validate();

            if (!isValid) {
              return;
            }

            if (!otpSent) {
              context.read<AuthBloc>().add(
                OtpSentEvent(
                  phoneNumber:
                      phoneController.text
                          .trim(),
                  isSignUp: true,
                ),
              );
            } else {
              context.read<AuthBloc>().add(
                OtpVerifiedEvent(
                  verificationId:
                      verificationId,
                  otp:
                      otpController.text.trim(),
                  name:
                      nameController.text.trim(),
                ),
              );

              log(
                'verificationId: '
                '$verificationId, '
                'otp: ${otpController.text}',
              );
            }
          },
        ),
          Row(
      mainAxisAlignment: MainAxisAlignment.values[2],
      children: [
        Text("Have an account?"
        , style: TextStyle(fontSize: 13, color: AppColours.lightText),),
        TextButton(onPressed: (){
          context.pushNamed(RouteConstants.login);
        }, child: Text('Login', 
        style: TextStyle(fontSize: 13.5, 
        color: AppColours.lightText, 
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
        decorationThickness: 1.5),))
      ],
    ),

        // ...
      ],
    ),
  );
}

}

           