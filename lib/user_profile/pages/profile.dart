import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/routing/route_constants.dart';
import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/user_profile/custom_widgets/text_field.dart';
import 'package:sleepy_driver/user_profile/custom_widgets/button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/auth/viewmodels/bloc/auth_bloc.dart';
import 'package:sleepy_driver/auth/custom_widgets/toast.dart';
import 'package:sleepy_driver/user_profile/viewmodels/bloc/user_profile_bloc.dart';

// profile page
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneNumController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return 
     Scaffold(
      body: MultiBlocListener(
        listeners: [
           BlocListener<UserProfileBloc, UserProfileState>(
              listener: (context, state) {
                log("Init state just got hit second time");
                // displaying user profile data
                if (state is UserProfileDisplayedState) {
                  nameController.text = state.user.name ?? 'Default';
                  phoneNumController.text = state.user.phoneNumber ?? 'Default';
                  locationController.text = 'Colombo';
                }}),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAccountDeletedState) {
                // deleting account
                  CustomToast.show(
                    context: context,
                    message: 'Your account was deleted successfully.',
                    bgColor: AppColours.success,
                    icon: Icons.error_outline,
                  );
                  context.pushNamed(RouteConstants.splash);
                  return;
                } 
               if (state is AuthLoggedOutState)
              {
                  // logging out account
                  CustomToast.show(
                    context: context,
                    message: 'You have been logged out.',
                    bgColor: AppColours.success,
                    icon: Icons.check_circle_outline,
                  );
                  context.pushNamed(RouteConstants.splash);
                  return;
              }
              if (state is AuthErrorState) {
                // error
                CustomToast.show(
                  context: context,
                  message: state.errorMessage,
                  icon: Icons.error_outline,
                );
              }
            },
          )],   
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 50),
                  _buildHeader(context),
                  SizedBox(height: 30),
                  _buildBody(),
                ],
              ),
            ),
          ),
        ),
      ));
  }

  @override
  void initState() {
    super.initState();  

    context.read<UserProfileBloc>().add(
    UserProfileDisplayedEvent(),
    
  );    
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'Your Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              //  fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: 10),
          CircleAvatar(
            radius: 57,
            backgroundColor: AppColours.primary,
            child: CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage('assets/images/img_profile_icon.png'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name', style: TextStyle(fontSize: 15)),
          SizedBox(height: 3),
          CustomProfileTextField(
            controller: nameController,
            icon: Icon(Icons.check, color: AppColours.primary),
          ),
          const SizedBox(height: 15),
          Text('Location', style: TextStyle(fontSize: 15)),
          SizedBox(height: 3),
          CustomProfileTextField(
            controller: locationController,
            icon: Icon(Icons.check, color: AppColours.primary),
          ),
          const SizedBox(height: 15),
          Text('Phone Number', style: TextStyle(fontSize: 15)),
          SizedBox(height: 3),
          CustomProfileTextField(
            icon: Icon(Icons.check, color: AppColours.primary),
            readOnly: true,
            controller: phoneNumController,
          ),
          const SizedBox(height: 30),

          // log out and delete buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8.0,
            children: [
              CustomProfileButton(
                text: 'Log Out',
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequestedEvent());
                },
              ),
              CustomProfileButton(
                text: 'Delete',
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text('Confirm Action'),
                      content: Text(
                        'Are you sure you want to delete your account? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(false),
                          child: Text('No'),
                        ), // dismiss i and takes back to prev screen
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              DeleteAccountRequestedEvent(),
                            );                           
                          },
                          child: Text('Yes'), // deletes the account
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
