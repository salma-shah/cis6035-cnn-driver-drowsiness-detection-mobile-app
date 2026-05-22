import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/routing/route_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
// using timer
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      // navigating to the next page after the timer ends
      context.pushNamed(RouteConstants.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 100),
              _buildHeader(context),
              _buildBody()
          ],
        ),
      ),
    );
  }
}

Widget _buildHeader(BuildContext context) {
  return Container(
    alignment: Alignment.center,
        child: Text(
          'SleepyDriver',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
          //  fontFamily: 'Montserrat',
            color: Theme.of(context).primaryColor
          ),
        ),
  );
}

Widget _buildBody() {
   return Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child:
              Image.asset('assets/images/img_landing_pg.jpg',
              width: double.infinity, fit: BoxFit.cover),
          ),
        );
}
