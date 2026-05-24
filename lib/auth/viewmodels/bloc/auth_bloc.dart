import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

// user related model & service
import 'package:sleepy_driver/auth/models/user.dart';
import 'package:sleepy_driver/auth/repos/auth_repo.dart';
import 'package:sleepy_driver/auth/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo authRepo = AuthRepo();
  final AuthService authService = AuthService();
  AuthBloc() : super(AuthInitialState()) {
    on<AuthEvent>((event, emit) {});

     on<OtpSentEvent>((event, emit) async {
      // log("EVENT WAS RECEIVED");
      emit(AuthLoadingState(isLoading: true));
      try {
        // checking if phone exists
        final exists = await authRepo.phoneExists(event.phoneNumber);
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

        final user = await authRepo.verifyOtp(
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
    
    
    on<LogoutRequestedEvent>((event, emit) async {
      emit (AuthLoadingState(isLoading: true));
      try {
        await authRepo.logOut();
        emit(AuthInitialState());
      } catch (e) 
      {
        log('Error logging out: $e');
        emit(AuthErrorState(errorMessage: 'Something went wrong with logging out!'));
      }});

      on<DeleteAccountRequestedEvent>((event, emit) async {
        emit(AuthLoadingState(isLoading: true));
        try {
          await authRepo.deleteUserAccount();
          emit(AuthInitialState());
        }
        catch (e)
        {
        log('Error logging out: $e');
        emit(AuthErrorState(errorMessage: 'Something went wrong with deleting the account!'));
        }
      });

  }
}