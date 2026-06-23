import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sleepy_driver/auth/custom_widgets/toast.dart';
import 'package:sleepy_driver/location/viewmodels/bloc/location_bloc.dart';
import 'package:sleepy_driver/shared/custom_widgets/button.dart';
import 'package:sleepy_driver/styles/app_colours.dart';
import 'package:sleepy_driver/home/custom_widgets/card.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/routing/route_constants.dart';

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
          
        BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
         // if (!mounted) return;
                // displaying user location data
                // real time!
            if (state is LocationLoadedState) {
                  log("Location LOADED HOME STATE");
                   return Text(
                    state.cityName!,   
            // location
          style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).primaryColor,                            
          ), 
          );
                  }
                  // error message
                // else if (state is LocationErrorState) {
                //    log("Location ERROR HOME STATE");
                //   CustomToast.show(
                //     context: context,
                //     message: state.errorMessage,
                //     bgColor : Theme.of(context).colorScheme.error,
                //     icon: Icons.error_outline,
                //   );
                // }
          return Text(  
            'Loading...' ,
            // location
          style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).primaryColor,                            
          ), 
          );
  },),
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
                    final now = snapshot.data ?? DateTime.now();
                    // day and date
                    return Text(DateFormat('EEEE,\n d MMM').format(now),
                    style: TextStyle(
                  fontSize: 20,
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
                SizedBox(width: 10),
                Flexible(
                  child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(fit: BoxFit.scaleDown,
                          child: StreamBuilder(stream: Stream.periodic(Duration(seconds: 1)), 
                          builder: (context, snapshot)
                          {  // time
                          final now = snapshot.data ?? DateTime.now();
                            return Text(DateFormat('h: mm a').format(now),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).primaryColor,
                            ),);
                          }),
                          ),                     // location txt
                        ],
                    ),
                  ),
                )
            ],
          ),
        ),
        SizedBox(height: 30,),
         // start trip button section
        CustomGeneralButton(
          onPressed: () {
            context.pushNamed(RouteConstants.safetyDashboard);
          }, 
          text: 'Start Trip',
          bgColor: Theme.of(context).colorScheme.secondary,
          txtColor: Theme.of(context).colorScheme.primary,
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
        HomeCard(onTap: () {
          context.pushNamed(RouteConstants.profile);
        },
        svgPath: 'assets/images/img_profile.svg',
        text: 'Profile',
        ),
        HomeCard(onTap: () {
          context.pushNamed(RouteConstants.safetyDashboard);
        },
        svgPath: 'assets/images/img_dashboard.svg',
        text:'Safety Dashboard',
        ),
        HomeCard(onTap: () {
           context.pushNamed(RouteConstants.userManualPg1);
        },
        svgPath: 'assets/images/img_user_manual.svg',
        text: 'User Manual',
        ),
        HomeCard(onTap: () {
         //  context.pushNamed(RouteConstants.userManualPg1);
        },
        svgPath: 'assets/images/img_suggestions.svg',
        text: 'Suggestions',
        ),
      ],
    );
  }
}