import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {

  Future<String?> getCurrentCity() async {

    // checking if location service is eneabled
    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled)
    {
      throw Exception('Location services disabled');
    }

    // permission given
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if(locationPermission == LocationPermission.denied)
    {
       locationPermission == await Geolocator.requestPermission();
    }
    if(locationPermission == LocationPermission.deniedForever)
    {
       throw Exception('Location permission denied');
    }

    // get current position
    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isEmpty)
    {
      log("Placemarks are empty");
      return null;
    }

    // returning the locality which is town name
    return placemarks.first.locality;
  }
}