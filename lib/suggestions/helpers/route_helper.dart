import 'package:latlong2/latlong.dart';
import 'package:sleepy_driver/suggestions/models/route_result.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteHelper {
  static const String endpoint =
      'https://router.project-osrm.org/route/v1/driving';

  Future<RouteResult> getRoute({
    required double startLatitude,
    required double startLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final url = Uri.parse(
      '$endpoint/'
      '$startLongitude,$startLatitude;'
      '$destinationLongitude,$destinationLatitude'
      '?overview=full'
      '&geometries=geojson'
    );

    final response = await http.get(
      url,
      headers: const {
        'User-Agent':
            'SleepyDriver/1.0',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Routing request failed: '
        '${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data['code'] != 'Ok') {
      throw Exception(
        'No driving route found.',
      );
    }

    final routes = data['routes'];

    if (routes is! List || routes.isEmpty) {
      throw Exception(
        'No route returned.',
      );
    }

    final route = routes.first;

    final geometry =
        route['geometry'];

    if (geometry is! Map) {
      throw Exception(
        'Route geometry unavailable.',
      );
    }

    final coordinates =
        geometry['coordinates'];

    if (coordinates is! List) {
      throw Exception(
        'Route coordinates unavailable.',
      );
    }

    final points = coordinates
        .whereType<List>()
        .where((coordinate) =>
            coordinate.length >= 2)
        .map(
          (coordinate) => LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          ),
        )
        .toList();

    return RouteResult(
      points: points,
      distanceKm:
          ((route['distance'] as num)
                  .toDouble()) /
              1000,
      durationMinutes:
          ((route['duration'] as num)
                  .toDouble()) /
              60,
    );
  }
}