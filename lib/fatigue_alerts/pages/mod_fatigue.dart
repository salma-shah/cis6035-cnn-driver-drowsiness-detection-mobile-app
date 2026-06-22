import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleepy_driver/shared/custom_widgets/button.dart';

class ModFatigue extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
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
              SvgPicture.asset('assets/images/img_mod_fatigue_stop.svg'),
              SizedBox(height: 20),
              Text(
                'Pull Over & Rest.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary
                ),
              )
         ],
       ),
      
     );
  }
  
  _buildBody(BuildContext context) {
    return Column(
      children: [
        Text('Moderate fatigue detected.',
        style: TextStyle(color: Colors.black,
        fontSize: 18.0),
        textAlign: TextAlign.center),
        SizedBox(height: 60.0),
        CustomGeneralButton(
          text: 'Stay Alert',
         onPressed: () {}, 
        bgColor: Theme.of(context).colorScheme.primary,
        txtColor: Theme.of(context).colorScheme.secondary,
        borderColor: Theme.of(context).colorScheme.primary,),
    // wake up button
      ],
    );
  }
}