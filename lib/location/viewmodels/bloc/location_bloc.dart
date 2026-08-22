import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sleepy_driver/location/repos/location_repo.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepo locationRepo = LocationRepo();
  LocationBloc() : super(LocationInitialState()) {
    on<LocationEvent>((event, emit) {});

    on<LocationDisplayedEvent>((event, emit) async {
      log("LOCATION DISPLAYED EVENT RECIEVED");
      emit(LocationInitialState());
      try 
      {
        final locationDisplayed = await locationRepo.getCurrentCity();
        if (locationDisplayed != null)
        {
          log("Location is going to be displayed");
          emit(LocationLoadedState(locationDisplayed));  
        }
        else 
        {
          log("Location is not going to be displayed");
          emit(LocationErrorState(errorMessage: 'Location could not be displayed.'));
        }
      }
      catch (e)
      {
        emit(LocationErrorState(errorMessage: e.toString()));
      }
    });

  }
}


// class LocationBloc extends Bloc<LocationEvent, LocationState> {
//   final LocationRepo locationRepo;

//   Timer? _locationTimer;

//   LocationBloc({
//     required this.locationRepo,
//   }) : super(LocationInitialState()) {

//     on<LocationDisplayedEvent>(onLocationDisplayed);

//     // Start periodic location updates
//     _locationTimer = Timer.periodic(
//       const Duration(minutes: 5),
//       (_) {
//         add(LocationDisplayedEvent());
//       },
//     );
//   }

//   Future<void> onLocationDisplayed(
//     LocationDisplayedEvent event,
//     Emitter<LocationState> emit,
//   ) async {
//     log("LOCATION DISPLAYED EVENT RECEIVED");

//     try {
//       final locationDisplayed =
//           await locationRepo.getCurrentCity();

//       if (locationDisplayed != null) {
//         log("Location is going to be displayed");

//         emit(
//           LocationLoadedState(locationDisplayed),
//         );
//       } else {
//         log("Location is not going to be displayed");

//         emit(
//           LocationErrorState(
//             errorMessage:
//                 'Location could not be displayed.',
//           ),
//         );
//       }
//     } catch (e) {
//       emit(
//         LocationErrorState(
//           errorMessage: e.toString(),
//         ),
//       );
//     }
//   }

//   @override
//   Future<void> close() {
//     _locationTimer?.cancel();
//     return super.close();
//   }
// }