part of 'auth_bloc.dart'; 

@immutable
abstract class AuthState {
  const AuthState();
  List<Object> get props => [];
}

final class AuthInitialState extends AuthState {}

final class AuthLoadingState extends AuthState {
  final bool isLoading;
  const AuthLoadingState({required this.isLoading});   // whether loading or not
}

final class AuthSuccessState extends AuthState {
  final UserModel user;
  const AuthSuccessState(this.user);

  @override
  List<Object> get props => [user];   // if user is authenticated, user will be used as a prop
}

final class AuthErrorState extends AuthState {
  final String errorMessage;
  const AuthErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];   // otherwise the error msg is a property

}
  // otp sent state
  final class OtpCodeSentState extends AuthState {
  final String verificationId;
  const OtpCodeSentState({required this.verificationId});
  }
