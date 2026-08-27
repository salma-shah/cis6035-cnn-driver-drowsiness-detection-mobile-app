import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleepy_driver/auth/repos/auth_repo.dart';
import 'package:sleepy_driver/auth/services/auth_service.dart';
import 'package:sleepy_driver/auth/services/auth_service_impl.dart';
import 'package:sleepy_driver/auth/viewmodels/bloc/auth_bloc.dart';
import 'package:sleepy_driver/trips/repos/trip_repo.dart';
import 'package:sleepy_driver/trips/services/trip_service.dart';
import 'package:sleepy_driver/trips/services/trip_service_impl.dart';
import 'package:sleepy_driver/trips/viewmodels/bloc/trip_bloc.dart';
import 'package:sleepy_driver/breaks/repos/break_repo.dart';
import 'package:sleepy_driver/breaks/services/break_service.dart';
import 'package:sleepy_driver/breaks/services/break_service_impl.dart';
import 'package:sleepy_driver/breaks/viewmodels/bloc/break_bloc.dart';
import 'package:sleepy_driver/alarm_system/repos/alert_repo.dart';
import 'package:sleepy_driver/alarm_system/services/alerts_service.dart';
import 'package:sleepy_driver/alarm_system/services/alerts_service_impl.dart';
import 'package:sleepy_driver/alarm_system/services/audio_service.dart';
import 'package:sleepy_driver/alarm_system/services/vibration_service.dart';
import 'package:sleepy_driver/alarm_system/facade/alarm_facade.dart';
import 'package:sleepy_driver/drowsiness_detection/helpers/drowsiness_detection_dep.dart';
import 'package:sleepy_driver/drowsiness_detection/repos/drowsiness_detection_repo.dart';
import 'package:sleepy_driver/drowsiness_detection/viewmodels/bloc/drowsiness_detection_bloc.dart';
import 'package:sleepy_driver/safety_tips/repos/safety_tip_repo.dart';
import 'package:sleepy_driver/safety_tips/services/safety_tip_service.dart';
import 'package:sleepy_driver/safety_tips/services/safety_tip_service_impl.dart';
import 'package:sleepy_driver/safety_tips/viewmodels/bloc/safety_tip_bloc.dart';
import 'package:sleepy_driver/location/services/location_service.dart';
import 'package:sleepy_driver/location/viewmodels/bloc/location_bloc.dart';
import 'package:sleepy_driver/suggestions/helpers/route_helper.dart';
import 'package:sleepy_driver/suggestions/recommendation_engine.dart';
import 'package:sleepy_driver/suggestions/repos/rec_repo.dart';
import 'package:sleepy_driver/suggestions/services/overpass_service.dart';
import 'package:sleepy_driver/suggestions/viewmodels/bloc/recommendations_bloc.dart';
import 'package:sleepy_driver/user_profile/viewmodels/bloc/user_profile_bloc.dart';


class CompositionRoot {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  late final AuthServiceInterface authService;
  late final AuthRepo authRepo;
  late final TripServiceInterface tripService;
  late final TripRepository tripRepository;
  late final BreakServiceInterface breakService;
  late final BreakRepo breakRepository;
  late final DrowsinessAlertServiceInterface drowsinessAlertService;
  late final DrowsinessAlertRepo drowsinessAlertRepo;
  late final AudioService audioService;
  late final VibrationService vibrationService;
  late final AlarmFacade alarmFacade;
  late final SafetyTipServiceInterface safetyTipService;
  late final SafetyTipRepo safetyTipRepo;
  late final LocationService locationService;
  late final OverpassService overpassService;
  late final RecommendationEngine recommendationEngine;
  late final RouteHelper routeHelper;
  late final RecommendationRepo recommendationRepo;
  late final DrowsinessDetectionRepo drowsinessDetectionRepo;
  CompositionRoot({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance,
        firestore =
            firestore ?? FirebaseFirestore.instance {
    _setup();
  }


  void _setup() {
    _setupAuth();
    _setupTrips();
    _setupBreaks();
    _setupAlerts();
    _setupAlarm();
    _setupSafetyTips();
    _setupRecommendations();
    _setupDrowsiness();
  }


  void _setupAuth() {
    authService = AuthServiceImpl(
    );

    authRepo = AuthRepo(
      authService: authService,
    );
  }
  void _setupTrips() {
    tripService = TripServiceImpl(
      firestore: firestore,
    );

    tripRepository = TripRepository(
      tripService: tripService,
      firebaseAuth: firebaseAuth,
    );
  }

  void _setupBreaks() {
    breakService = BreakServiceImpl(
      firestore: firestore,
      firebaseAuth: firebaseAuth,
    );

    breakRepository = BreakRepo(
      service: breakService,
    );
  }

  void _setupAlerts() {
    drowsinessAlertService =
        DrowsinessAlertServiceImpl(
      firestore: firestore,
      firebaseAuth: firebaseAuth,
    );

    drowsinessAlertRepo =
        DrowsinessAlertRepo(
      service: drowsinessAlertService,
    );
  }
  void _setupAlarm() {
    audioService = AudioService();

    vibrationService = VibrationService();

    alarmFacade = AlarmFacade(
      audioService: audioService,
      vibrationService: vibrationService,
    );
  } 

  void _setupSafetyTips() {
    safetyTipService =
        SafetyTipServiceImpl(
      firestore: firestore,
    );

    safetyTipRepo = SafetyTipRepo(
      service: safetyTipService,
    );
  }


  void _setupRecommendations() {
    locationService = LocationService();

    overpassService = OverpassService();

    recommendationEngine =
        RecommendationEngine();

    routeHelper = RouteHelper();

    recommendationRepo =
        RecommendationRepo(
      locationService: locationService,
      overpassService: overpassService,
      recommendationEngine:
          recommendationEngine,
      routeHelper: routeHelper,
    );
  }

  void _setupDrowsiness() {
    drowsinessDetectionRepo =
        createDrowsinessRepository();
  }


  AuthBloc createAuthBloc() {
    return AuthBloc(
      authRepo: authRepo,
    );
  }

  TripBloc createTripBloc() {
    return TripBloc(
      tripRepository: tripRepository,
    );
  }

  BreakBloc createBreakBloc() {
    return BreakBloc(
      repository: breakRepository,
    );
  }

  SafetyTipBloc createSafetyTipBloc() {
    return SafetyTipBloc(
      repository: safetyTipRepo,
    );
  }

  RecommendationBloc createRecommendationBloc() {
    return RecommendationBloc(
      repository: recommendationRepo,
    );
  }

  DrowsinessBloc createDrowsinessBloc() {
    return DrowsinessBloc(
      repository: drowsinessDetectionRepo,
      alarmFacade: alarmFacade,
      alertRepository: drowsinessAlertRepo,
    );
  }

  UserProfileBloc createUserProfileBloc() {
    return UserProfileBloc();
  }

  LocationBloc createLocationBloc() {
    return LocationBloc();
  }
}