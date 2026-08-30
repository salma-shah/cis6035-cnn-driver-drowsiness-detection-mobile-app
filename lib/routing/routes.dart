import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/auth/pages/login.dart';
import 'package:sleepy_driver/auth/pages/sign_up.dart';
import 'package:sleepy_driver/dashboard/pages/safety_dashboard.dart';
import 'package:sleepy_driver/drowsiness_detection/fatigue_severity.dart';
import 'package:sleepy_driver/alarm_system/pages/mild_fatigue.dart';
import 'package:sleepy_driver/alarm_system/pages/mod_fatigue.dart';
import 'package:sleepy_driver/alarm_system/pages/severe_fatigue.dart';
import 'package:sleepy_driver/splash/pages/splash.dart';
import 'package:sleepy_driver/home/pages/home.dart';
import 'package:sleepy_driver/nav_bar/layout.dart';
import 'package:sleepy_driver/suggestions/pages/safety_suggestions.dart';
import 'package:sleepy_driver/trips/pages/trip_history.dart';
import 'package:sleepy_driver/user_manual/pages/um_pg1.dart';
import 'package:sleepy_driver/user_manual/pages/um_pg2.dart';
import 'package:sleepy_driver/user_manual/pages/um_pg3.dart';
import 'package:sleepy_driver/user_manual/pages/um_pg4.dart';
import 'package:sleepy_driver/user_manual/pages/um_pg5.dart';
import 'package:sleepy_driver/user_profile/pages/profile.dart';
import 'package:sleepy_driver/routing/route_constants.dart';

final routerKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter{
  late final GoRouter router = GoRouter(
    navigatorKey: routerKey,
    initialLocation: RouteConstants.splash,
    routes: [
      GoRoute(name: RouteConstants.splash, path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(name: RouteConstants.signUp, path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(name: RouteConstants.login, path: '/login', builder: (context, state) => const LoginPage()), 
      GoRoute(name: RouteConstants.mildFatigue, path: '/mild-fatigue', builder: (context, state) => MildFatiguePage()),
      GoRoute(name: RouteConstants.modFatigue, path: '/mod-fatigue', builder: (context, state) => ModFatigue(),),
      GoRoute(name: RouteConstants.severeFatigue, path: '/severe-fatigue', builder: (context, state) => SevereFatiguePage()),
      GoRoute(path: '/safety-suggestions', name: RouteConstants.safetySuggestions, builder: (context, state) {
        final severity =
        state.extra as FatigueSeverity? ??
            FatigueSeverity.normal;
        return SafetySuggestionsPage(severity: severity);}),
      GoRoute(name: RouteConstants.userManualPg1, path: '/user-manual-pg1' , builder: (context, state) => UserManualPg1()),
      GoRoute(name: RouteConstants.userManualPg2, path: '/user-manual-pg2' , builder: (context, state) => UserManualPg2()),
      GoRoute(name: RouteConstants.userManualPg3, path: '/user-manual-pg3' , builder: (context, state) => UserManualPg3()),
      GoRoute(name: RouteConstants.userManualPg4, path: '/user-manual-pg4' , builder: (context, state) => UserManualPg4()),
      GoRoute(name: RouteConstants.userManualPg5, path: '/user-manual-pg5' , builder: (context, state) => UserManualPg5()),
      GoRoute(name: RouteConstants.tripHistory, path: '/trip-history', builder: (context, state) => TripHistoryPage()),
    // statefull shell route for the nav bar
    StatefulShellRoute.indexedStack(
  branches: [
    // home
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          name: RouteConstants.home,
          builder: (context, state) =>
              HomePage(),
        ),
      ],
    ),

    // safety dashboard
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/safety-dashboard',
          name: RouteConstants.safetyDashboard,
          builder: (context, state) =>
              SafetyDashboardPage(),
        ),
      ],
    ),

// profile
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/profile',
          name: RouteConstants.profile,
        //   builder: (context, state) =>
        //   log('PROFILE ROUTE BUILDER'),
        //       ProfilePage(),
        // ),
         builder: (context, state) {
    log('PROFILE ROUTE BUILDER');
    return ProfilePage();
  },)
      ],
    ),
  ],

  builder:
      (context, state, navigationShell) {
    return DefaultLayout(
      navigationShell:
          navigationShell,
    );
      })]);

}