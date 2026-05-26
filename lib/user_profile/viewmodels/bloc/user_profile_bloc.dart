import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sleepy_driver/auth/models/user.dart';
import 'package:sleepy_driver/user_profile/repos/user_profile_repo.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepo userProfileRepo = UserProfileRepo();
  UserProfileBloc() : super(UserProfileInitialState()) {
    on<UserProfileEvent>((event, emit) {});

    on<UserProfileUpdatedEvent>((event, emit) async {
      log("USER PROFILE UPDATE EVENT RECIEVED");
      emit(UserProfileLoadingState(isLoading: true));
      try 
      {
        await userProfileRepo.updateUserName(event.values);
        final updatedUserProfile = await userProfileRepo.getUserProfile();
        if (updatedUserProfile != null) {
          emit(UserProfileSuccessState(updatedUserProfile));
        } else {
          emit(UserProfileErrorState(errorMessage: 'Something went wrong with updating the user profile.'));
        }
      }
      catch (e)
      {
        emit(UserProfileErrorState(errorMessage: e.toString()));
      }
    });

    // getting the user profile
    on<UserProfileDisplayedEvent>((event, emit) async 
    {
      log("USER PROFILE EVENT RECIEVED");
      emit(UserProfileLoadingState(isLoading: true));
      try 
      {
        final userProfile = await userProfileRepo.getUserProfile();
        if (userProfile != null)
        {
          log("User profile is going to be displayed");
          emit(UserProfileDisplayedState(userProfile));       
        }
        else 
        {
          log("User profile is not going to be displayed");
          emit(UserProfileErrorState(errorMessage: 'Something went wrong with displaying the user profile!'));
        }
      }
      catch (e)
      {
        emit(UserProfileErrorState(errorMessage: e.toString()));
      }
    });
  }
}
