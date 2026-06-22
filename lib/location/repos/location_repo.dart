import 'package:sleepy_driver/location/services/location_service.dart';

class LocationRepo
{
  final LocationService locationService =  LocationService();

  // getting the city
  Future<String?> getCurrentCity() async {
    return locationService.getCurrentCity();
  }

}