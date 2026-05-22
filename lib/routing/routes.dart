import 'package:go_router/go_router.dart';
import 'package:sleepy_driver/auth/pages/login.dart';
import 'package:sleepy_driver/auth/pages/sign_up.dart';
import 'package:sleepy_driver/splash/pages/splash.dart';
import 'package:sleepy_driver/home/pages/home.dart';
import 'package:sleepy_driver/routing/route_constants.dart';

class AppRouter{
  GoRouter get router => GoRouter(
    routes: [
      GoRoute(name: RouteConstants.splash, path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(name: RouteConstants.signUp, path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(name: RouteConstants.login, path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(name: RouteConstants.home, path: '/home', builder: (context, state) => const HomePage())
    ]
  );
}