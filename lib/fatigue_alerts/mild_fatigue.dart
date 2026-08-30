import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleepy_driver/custom_widgets/button.dart';
import 'package:sleepy_driver/styles/app_colours.dart';

class MildFatiguePage extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 50),
                  _buildHeader(context),
                  SizedBox(height: 20),
                  _buildBody()
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
                  color: AppColours.accent
                ),
              )
         ],
       ),
      
     );
  }
  
  _buildBody() {
    return Column(
      children: [
        Text('Slight fatigue detected.',
        style: TextStyle(color: Colors.white,
        fontSize: 19.0),
        textAlign: TextAlign.center),
        SizedBox(height: 60.0),
        CustomGeneralButton(
          text: 'Wake Up',
         onPressed: () {}, 
        bgColor: AppColours.accent,
        txtColor: AppColours.primary),
    // wake up button
      ],
    );
  }

}