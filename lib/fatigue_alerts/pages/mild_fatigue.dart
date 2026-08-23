import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_bloc.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_event.dart';
import 'package:sleepy_driver/shared/custom_widgets/button.dart';

class MildFatiguePage extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 50),
                  _buildHeader(context),
                  SizedBox(height: 20),
                  _buildBody(context)
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  _buildHeader(BuildContext context) {
     return Padding(
       padding: const EdgeInsets.all(20.0),
       child: Column(
         children: [
              SvgPicture.asset('assets/images/img_mild_fatigue_stop.svg'),
              SizedBox(height: 20),
              Text(
                'Take A Break.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.secondary
                ),
              )
         ],
       ),
      
     );
  }
  
  _buildBody(BuildContext context) {
    return Column(
      children: [
        Text('Slight fatigue detected.',
        style: TextStyle(color: Colors.white,
        fontSize: 18.0),
        textAlign: TextAlign.center),
        SizedBox(height: 60.0),
        CustomGeneralButton(
          text: 'Wake Up',
         onPressed: () {
            context.read<DrowsinessBloc>().add(
              const DrowsinessAlarmDismissed() // dismisses the alarm
            );
            context.pop();
          },
        bgColor: Theme.of(context).colorScheme.secondary,
        txtColor: Theme.of(context).colorScheme.primary),
    // wake up button
      ],
    );
  }

}