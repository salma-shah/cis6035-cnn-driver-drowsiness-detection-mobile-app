part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
  List<Object> get props => [];
}

class LogoutRequestedEvent extends AuthEvent {}

class DeleteAccountRequestedEvent extends AuthEvent{}

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