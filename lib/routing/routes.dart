import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/auth/pages/login.dart';
import 'package:sleepy_driver/auth/pages/sign_up.dart';
import 'package:sleepy_driver/fatigue_alerts/mild_fatigue.dart';
import 'package:sleepy_driver/splash/pages/splash.dart';
import 'package:sleepy_driver/home/pages/home.dart';
import 'package:sleepy_driver/user_profile/pages/profile.dart';
import 'package:sleepy_driver/routing/route_constants.dart';

class AppRouter{
  GoRouter get router => GoRouter(
    routes: [
      GoRoute(name: RouteConstants.splash, path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(name: RouteConstants.signUp, path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(name: RouteConstants.login, path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(name: RouteConstants.home, path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(name: RouteConstants.profile, path: '/profile', builder: (context, state) => const ProfilePage()), 
      GoRoute(name: RouteConstants.mildFatigue, path: '/mild-fatigue', builder: (context, state) => MildFatiguePage())  
    ]
  );
}