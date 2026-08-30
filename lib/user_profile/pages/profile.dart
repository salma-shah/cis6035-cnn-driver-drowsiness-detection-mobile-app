import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/location/viewmodels/bloc/location_bloc.dart';
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
  final TextEditingController nameController = TextEditingController(text: 'No name.');
  final TextEditingController locationController = TextEditingController(text: 'No Location');
  final TextEditingController phoneNumController = TextEditingController(text: 'No phone number.');

  // focus nodes
  final FocusNode focusNameNode = FocusNode();
  bool isNameFocused = false;

   @override
  void initState() {
    super.initState(); 
    log('PROFILE INIT'); 
    context.read<UserProfileBloc>().add(
    UserProfileDisplayedEvent(),
  );    
   focusNameNode.addListener(() {
      setState(() {
        isNameFocused = focusNameNode.hasFocus;
      });
    });

// loading location event
    log("LOCATION IN USER PROF INIT");
    context.read<LocationBloc>().add(
    LocationDisplayedEvent(),
  ); 
  }

    @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    phoneNumController.dispose();
    focusNameNode.dispose();
    log('PROFILE DIS');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('PROFILE BUILD');
    return 
     Scaffold(
      body: MultiBlocListener(
        listeners: [
           BlocListener<UserProfileBloc, UserProfileState>(
              listener: (context, state) {
               // log("Init state just got hit second time");
             //    log('USER PROFILE STATE: ${state.runtimeType}');
                if (!mounted) return;
                // displaying user profile data
                if (state is UserProfileDisplayedState) {
                  nameController.text = state.user.name ;
                  phoneNumController.text = state.user.phoneNumber ;
                 }

                // updated profile succcess / error
                if (state is UserProfileSuccessState) {
                  CustomToast.show(
                    context: context,
                    message: 'Profile updated successfully.',
                    bgColor: AppColours.success,
                    icon: Icons.check_circle_outline,
                  );
                } else if (state is UserProfileErrorState) {
                  CustomToast.show(
                    context: context,
                    message: state.errorMessage,
                    bgColor : Theme.of(context).colorScheme.error,
                    icon: Icons.error_outline,
                  );
                }
  }),
  BlocListener<LocationBloc, LocationState>(
              listener: (context, state) {
               if (!mounted) return;
                // displaying user location data
                // real time!
                if (state is LocationLoadedState) {
                  log("Location LOADED STATE");
                  locationController.text = state.cityName!;}

                  // error message
                else if (state is LocationErrorState) {
                   log("Location ERROR STATE");
                  CustomToast.show(
                    context: context,
                    message: state.errorMessage,
                    bgColor : Theme.of(context).colorScheme.error,
                    icon: Icons.error_outline,
                  );
                }
  }),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async {
               log('AUTH STATE CHANGED: $state');
               log('AUTH STATE CHANGED: ${state.runtimeType}');
              if (state is AuthAccountDeletedState) {
                // deleting account
                  CustomToast.show(
                    context: context,
                    message: 'Your account was deleted successfully.',
                    bgColor: AppColours.success,
                    icon: Icons.error_outline,
                  );
                  context.goNamed(RouteConstants.splash);
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
                  await Future.delayed(const Duration(seconds: 2));
                  if (!mounted) return;

                  context.goNamed(RouteConstants.splash);
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
          ),
          ],   
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
            radius: 72,
            backgroundColor: AppColours.primary,
            child: CircleAvatar(
              radius: 70,
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
            focusNode: focusNameNode,
            icon: isNameFocused ?
            IconButton(
              icon: Icon(Icons.check, color: AppColours.primary),
              onPressed: () {
                context.read<UserProfileBloc>().add(
                  UserProfileUpdatedEvent(values: {
                    'name': nameController.text,
                  }),
                );
              //  nameController.clear();
              },
            ) : null,
          ),
          const SizedBox(height: 15),
          Text('Location', style: TextStyle(fontSize: 15)),
          SizedBox(height: 3),
          CustomProfileTextField(
            controller: locationController,
           //  focusNode: focusLocationNode,
            // icon: isLocationFocused ?
            // IconButton(
            //   icon: Icon(Icons.check, color: AppColours.primary),
            //   onPressed: () {
            //     context.read<UserProfileBloc>().add(
            //       UserProfileUpdatedEvent(values: {
            //         'location': locationController.text,
            //       }),
            //     );
            //     locationController.clear();
            //   },
            // ) : null,
          ),
          const SizedBox(height: 15),
          Text('Phone Number', style: TextStyle(fontSize: 15)),
          SizedBox(height: 3),
          CustomProfileTextField(
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
                //  context.pushNamed(RouteConstants.splash);
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
                        ), // dismiss it and takes back to prev screen
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              DeleteAccountRequestedEvent(),
                            );  
                          //  context.pushNamed(RouteConstants.splash);                         
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
          const SizedBox(height: 18),
          SizedBox(
  width: double.infinity,
  child: CustomProfileButton(
    text: 'Trip History',
    onPressed: () {
      context.pushNamed(
        RouteConstants.tripHistory,
      );
    },
  ),
          ),
        ],
      ),
    );
  }
}
