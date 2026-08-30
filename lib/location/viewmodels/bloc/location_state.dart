part of 'location_bloc.dart';

@immutable
abstract class LocationState {
  const LocationState();
  List<Object> get props => [];
}

final class LocationInitialState extends LocationState {}

final class LocationLoadedState extends LocationState {
  final String? cityName;

  LocationLoadedState(this.cityName);
}

final class LocationErrorState extends LocationState {
 final String errorMessage;
  const LocationErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];   // the error msg is a property
}

