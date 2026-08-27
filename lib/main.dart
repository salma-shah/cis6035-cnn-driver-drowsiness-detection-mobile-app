import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sleepy_driver/core/composition_root.dart';
import 'package:sleepy_driver/firebase_options.dart';
import 'package:sleepy_driver/routing/routes.dart';
import 'package:sleepy_driver/styles/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final compositionRoot = CompositionRoot();

  runApp(
    MyApp(
      compositionRoot: compositionRoot,
    ),
  );
}

class MyApp extends StatelessWidget {
  final CompositionRoot compositionRoot;

  const MyApp({
    super.key,
    required this.compositionRoot,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              compositionRoot.createAuthBloc(),
        ),
        BlocProvider(
  create: (_) =>
      compositionRoot.createUserProfileBloc(),
),

BlocProvider(
  create: (_) =>
      compositionRoot.createLocationBloc(),
),
        BlocProvider(
          create: (_) =>
              compositionRoot.createTripBloc(),
        ),

        BlocProvider(
          create: (_) =>
              compositionRoot.createBreakBloc(),
        ),

        BlocProvider(
          create: (_) =>
              compositionRoot.createSafetyTipBloc(),
        ),

        BlocProvider(
          create: (_) =>
              compositionRoot.createRecommendationBloc(),
        ),

        BlocProvider(
          create: (_) =>
              compositionRoot.createDrowsinessBloc(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'SleepyDriver Main Page',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter().router,
      ),
    );
  }
}