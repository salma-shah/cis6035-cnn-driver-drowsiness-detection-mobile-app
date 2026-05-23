part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
  List<Object> get props => [];
}

class UserSignedUpEvent extends AuthEvent {
  final String name;
  final String phoneNumber;
  final Function(String) onCodeSent;

  const UserSignedUpEvent({required this.name, required this.phoneNumber, required this.onCodeSent});

  @override
  List<Object> get props => [phoneNumber];
}

class UserLoggedOutEvent extends AuthEvent {}

class UserLoggedInEvent extends AuthEvent {
  final String phoneNumber;
  final String verificationId;

  const UserLoggedInEvent({required this.phoneNumber, required this.verificationId});

  @override
  List<Object> get props => [phoneNumber, verificationId];
}

class OtpSentEvent extends AuthEvent {
  final String phoneNumber;
  final bool isSignUp;

  const OtpSentEvent({required this.phoneNumber, required this.isSignUp});

  @override
  List<Object> get props => [phoneNumber];
}

class OtpVerifiedEvent extends AuthEvent {
  final String verificationId;
  final String otp;
  final String? name;

  const OtpVerifiedEvent({required this.verificationId, required this.otp, required this.name});

  @override
  List<Object> get props => [verificationId, otp];
}