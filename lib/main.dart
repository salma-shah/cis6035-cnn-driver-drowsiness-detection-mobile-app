import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepy_driver/auth/viewmodels/bloc/auth_bloc.dart';
import 'package:sleepy_driver/styles/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sleepy_driver/firebase_options.dart';
import 'package:sleepy_driver/routing/routes.dart';
import 'package:sleepy_driver/user_profile/viewmodels/bloc/user_profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp
  (
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => UserProfileBloc()),
      ],
      child: MyApp(),
    ));
}

// landing page for app
class MyApp extends StatelessWidget {
   MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
   return MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'SleepyDriver Main Page',
    theme: AppTheme.lightTheme,
    routerConfig: _appRouter.router,
   );
  }

  
}