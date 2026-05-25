import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleepy_driver/custom_widgets/button.dart';
import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/home/custom_widgets/card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                  SizedBox(height: 35), 
                    _buildHeader(context), 
                    SizedBox(height: 50),
                    _buildBody(context)       
                ],
              ),
            ),
            ),
      ),
    );
}
  
  _buildHeader(BuildContext context) {
     return Container(
    alignment: Alignment.center,
    child: Column(
      children: [
        Row(
          children: [
          Icon(Icons.location_on_outlined, 
          color: AppColours.primary,
         size: 25.0,),                            
          Text(   
            // location
          'Polannaruwa',
          style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).primaryColor,                            
          ), 
          ),
          ],
           ),
           SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                child: StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)), 
                  builder: (context, snapshot)
                  {
                    // day and date
                    return Text(DateFormat('EEEE,\n d MMM').format(DateTime.now()),
                    style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                    ),);  // current date formatted 
                  }),
              ),
              SizedBox(width: 10),
                // line in between
                VerticalDivider(
                  color: AppColours.primary,
                  thickness: 2,
                ),
                SizedBox(width: 10,),
                Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreamBuilder(stream: Stream.periodic(Duration(seconds: 1)), 
                        builder: (context, snapshot)
                        {  // time
                          return Text(DateFormat('h: mm a').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                          ),);
                        }),
                        // location txt
                      ],
                  ),
                )
            ],
          ),
        ),
        SizedBox(height: 30,),
         // start trip button section
        CustomGeneralButton(
          onPressed: () {}, 
          text: 'Start Trip',
          bgColor: AppColours.accent,
          txtColor: AppColours.primary,
          )
      ],
    ),  
  );
  }
  
  _buildBody(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 6,
      mainAxisSpacing: 20,
      children: [
        HomeCard(onTap: () {},
        svgPath: 'assets/images/img_settings.svg',
        text: 'Settings',
        ),
        HomeCard(onTap: () {},
        svgPath: 'assets/images/img_dashboard.svg',
        text:'Safety Dashboard',
        ),
        HomeCard(onTap: () {},
        svgPath: 'assets/images/img_user_manual.svg',
        text: 'User Manual',
        ),
        HomeCard(onTap: () {},
        svgPath: 'assets/images/img_suggestions.svg',
        text: 'Suggestions',
        ),
      ],
    );
  }
}