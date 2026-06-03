part of 'user_profile_bloc.dart';

@immutable
abstract class UserProfileEvent {
  const UserProfileEvent();
  List<Object> get props => [];
}

class UserProfileDisplayedEvent extends UserProfileEvent{}

class UserProfileUpdatedEvent extends UserProfileEvent
{
  final Map<String,dynamic> values;

  const UserProfileUpdatedEvent({required this.values});
  
  @override
  List<Object> get props => [values];
}




