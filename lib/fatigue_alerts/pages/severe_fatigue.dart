import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleepy_driver/shared_custom_widgets/button.dart';

class SevereFatiguePage extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.error,
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
              SvgPicture.asset('assets/images/img_severe_fatigue_stop.svg',),
              SizedBox(height: 20),
              Text(
                'Stop Driving!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white
                ),
              )
         ],
       ),
     );
  }
  
  _buildBody(BuildContext context) {
    return Column(
      children: [
        Text('Extreme drowsiness detected.',
        style: TextStyle(color: Colors.white,
        fontSize: 18.0),
        textAlign: TextAlign.center),
        SizedBox(height: 60.0),
        CustomGeneralButton(
          text: 'Get Suggestions',
         onPressed: () {}, 
        bgColor: Colors.white,
        txtColor: Theme.of(context).colorScheme.error,
        borderColor: Theme.of(context).colorScheme.error),
    // wake up button
      ],
    );
  }

  
}