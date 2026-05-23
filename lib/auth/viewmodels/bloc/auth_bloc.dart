import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

// user related model & service
import 'package:sleepy_driver/auth/models/user.dart';
import 'package:sleepy_driver/auth/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService = AuthService();
  AuthBloc() : super(AuthInitialState()) {
    on<AuthEvent>((event, emit) {});

     on<OtpSentEvent>((event, emit) async {
      // log("EVENT WAS RECEIVED");
      emit(AuthLoadingState(isLoading: true));
      try {
        // checking if phone exists
        final exists = await authService.phoneExists(event.phoneNumber);
        if (exists && event.isSignUp)
        {
          emit(AuthErrorState(errorMessage: 'This phone number is already registered'));
          return;
        }
        if (!exists && !event.isSignUp)
        {
          emit(AuthErrorState(errorMessage: 'No account found for this phone number.'));
          return;
        }

      final verificationId =
      await authService.sendOtp(
      event.phoneNumber);
      
      log("OTP WAS SENT");
      emit(
      OtpCodeSentState(
        verificationId: verificationId,
      ),
      );
      } catch (e) {
        log('Error sending OTP: $e');
        emit(AuthErrorState(errorMessage: 'Failed to send OTP'));
      } 
  });

  on<OtpVerifiedEvent>((event, emit) async {
      emit(AuthLoadingState(isLoading: true));
      try {

        final user = await authService.verifyOtp(
          event.verificationId,
          event.otp,
          event.name,
        );
        emit(AuthSuccessState(user));
      } catch (e) {
        log('Error verifying OTP: $e');
        emit(AuthErrorState(errorMessage: 'Failed to verify OTP'));
      }
  });
    
    
    on<UserLoggedOutEvent>((event, emit) async {
          emit (AuthLoadingState(isLoading: true));
          try {
            await authService.firebaseAuth.signOut();
            emit(AuthInitialState());
          } catch (e) {
            log('Error logging out: $e');
            emit(AuthErrorState(errorMessage: 'Failed to log out'));
          }});


    // phone number check 
    // on<PhoneCheckedEvent>((event, emit) async {
    //   emit(AuthLoadingState(isLoading: true));
    //   try 
    //   {
    //     final result = await FirebaseFunctions.instance.httpsCallable(
    //       'checkIfPhoneNumberIsRegistered'
    //     ).call({'phone' :  event.phoneNumber});

    //     // if phone number exists
    //     if (result.data['exists']){
    //       emit(PhoneExistsState(result.data['uid']));
    //     }
    //     else 
    //     {
    //       emit(PhoneDoesNotExistState());
    //     }
    //   }
    //   catch(e)
    //   {
    //     log('Error checking phone number: $e');
    //     emit(AuthErrorState(errorMessage: 'Failed to check phone number'));
    //   }
    // });
  }
}