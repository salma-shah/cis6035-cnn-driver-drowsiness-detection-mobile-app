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
      
      // when signng up the user
      on<UserSignedUpEvent>((event, emit) async {
        emit(AuthLoadingState(isLoading: true));
        try 
        {
         final UserModel? user = await authService.signUp(
            event.phoneNumber,
            event.name,
            event.onCodeSent as String,
          );
          if (user != null) {
            emit(AuthSuccessState(user: user));
          } else {
            emit(AuthErrorState(errorMessage: 'Failed to sign up user'));
          }
        }
          catch (e) { log('Error signing in with phone number: $e');
          }
  });

     on<OtpSentEvent>((event, emit) async {
      // log("EVENT WAS RECEIVED");
      emit(AuthLoadingState(isLoading: true));
      try {
        final verificationId =
      await authService.sendOtp(
      event.phoneNumber);
      
      log("OTP WAS SENT");
      emit(
      OtpCodeSentState(
        verificationId: verificationId,
      ),
      );
      emit(AuthSucessMsgState(successMessage: 'OTP sent successfully'));
      } catch (e) {
        log('Error sending OTP: $e');
        emit(AuthErrorState(errorMessage: 'Failed to send OTP'));
      } 
  });

  on<OtpVerifiedEvent>((event, emit) async {
      emit(AuthLoadingState(isLoading: true));
      try {
        final UserModel? user = await authService.verifyOtp(
          event.verificationId,
          event.otp,
        );
        if (user != null) {
          emit(AuthSuccessState(user: user));
        } else {
          emit(AuthErrorState(errorMessage: 'Invalid OTP'));
        }
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
  }
}