part of 'user_profile_bloc.dart';

@immutable
abstract class UserProfileState {
  const UserProfileState();
  List<Object> get props => [];
}

final class UserProfileInitialState extends UserProfileState {}

final class UserProfileLoadingState extends UserProfileState {
  final bool isLoading;
  const UserProfileLoadingState({required this.isLoading});   // whether loading or not
}

final class UserProfileDisplayedState extends UserProfileState
{
   final UserModel user;
   const UserProfileDisplayedState(this.user);

  @override
  List<Object> get props => [user]; 
}

final class UserProfileSuccessState extends UserProfileState {
  final UserModel user;
  const UserProfileSuccessState(this.user);

  @override
  List<Object> get props => [user];   // if user func is successful, user will be used as a prop
}

final class UserProfileErrorState extends UserProfileState {
  final String errorMessage;
  const UserProfileErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];   // otherwise the error msg is a property
}

