import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/routing/route_constants.dart';
import 'package:sleepy_driver/user_manual/custom_widgets/button.dart';
import 'package:sleepy_driver/user_manual/custom_widgets/number_badge.dart';

class UserManualPg5 extends StatelessWidget{
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30),
                  _buildHeader(context),
                  SizedBox(height: 56),
                  _buildBody(context)
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  _buildHeader(BuildContext context) {
     return 
      Column(
         children: [
              SizedBox(height: 10),
              Text(
                'User Manual',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
              Text(
                'Steps to follow if you need assistance with the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24),
              // number
              NumberBadge(
                number: 5,
              )
         ]);
  }
  
  _buildBody(BuildContext context) {
    return Column(
      children:[
        Image.asset('assets/images/img_user_manual_pg5.png'),
        SizedBox(height: 50),
        Text('Drive Safe!',
        style: TextStyle(
          fontSize: 23.5,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary
        ),
        textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        CustomUserManualButton(
          text:'Done',
          onPressed: (){
            context.goNamed(RouteConstants.home);
          }
        )
      ]
    );
  }
  
}