import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:sleepy_driver/location/models/driver_location.dart';
import 'package:sleepy_driver/suggestions/models/rest_stop.dart';

class OverpassService {
  static const String endpoint =
      'https://overpass-api.de/api/interpreter';

  static const String userAgent =
      'SleepyDriver/1.0 '
      '(student driver drowsiness monitoring application)';

  Future<List<RestStop>> findNearbyRestStops({
    required DriverLocation location,
    double radiusMeters = 5000,
  }) async {
    final query = '''
[out:json][timeout:20];

(
  nwr["amenity"="cafe"](around:${radiusMeters},${location.latitude},${location.longitude});
  nwr["amenity"="restaurant"](around:${radiusMeters},${location.latitude},${location.longitude});
  nwr["amenity"="fast_food"](around:${radiusMeters},${location.latitude},${location.longitude});
  nwr["amenity"="fuel"](around:${radiusMeters},${location.latitude},${location.longitude});
  nwr["highway"="rest_area"](around:${radiusMeters},${location.latitude},${location.longitude});
  nwr["highway"="services"](around:${radiusMeters},${location.latitude},${location.longitude});
  nwr["amenity"="parking_space"](around:${radiusMeters},${location.latitude},${location.longitude});
);

out center tags;
''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'User-Agent': userAgent,
        'Content-Type':
            'application/x-www-form-urlencoded',
      },
      body: {
        'data': query,
      },
    );

    if (response.statusCode == 429) {
      throw Exception(
        'OpenStreetMap is temporarily busy. '
        'Please try again shortly.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'OpenStreetMap request failed: '
        '${response.statusCode}',
      );
    }

    final decoded =
        jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid OpenStreetMap response.',
      );
    }

    final elements =
        decoded['elements'];

    if (elements is! List) {
      return [];
    }

    final results = <RestStop>[];

    for (final element in elements) {
      if (element is! Map<String, dynamic>) {
        continue;
      }

      final stop =
          parseElement(
        element,
        driverLatitude:
            location.latitude,
        driverLongitude:
            location.longitude,
      );

      if (stop != null) {
        results.add(stop);
      }
    }

    results.sort(
      (a, b) =>
          a.distanceKm.compareTo(
        b.distanceKm,
      ),
    );

    return results;
  }

  RestStop? parseElement(
    Map<String, dynamic> element, {
    required double driverLatitude,
    required double driverLongitude,
  }) {
    final tags = element['tags'];

    if (tags is! Map) {
      return null;
    }

    final name =
        tags['name']?.toString();

    if (name == null ||
        name.trim().isEmpty) {
      return null;
    }

    double? latitude;
    double? longitude;

    final directLat = element['lat'];
    final directLon = element['lon'];

    if (directLat is num &&
        directLon is num) {
      latitude = directLat.toDouble();
      longitude = directLon.toDouble();
    }

    if (latitude == null ||
        longitude == null) {
      final center = element['center'];

      if (center is Map) {
        final centerLat = center['lat'];
        final centerLon = center['lon'];

        if (centerLat is num &&
            centerLon is num) {
          latitude =
              centerLat.toDouble();

          longitude =
              centerLon.toDouble();
        }
      }
    }

    if (latitude == null ||
        longitude == null) {
      return null;
    }

    final distance =
        haversineDistanceKm(
      driverLatitude,
      driverLongitude,
      latitude,
      longitude,
    );

    final amenity =
        tags['amenity']?.toString();

    final highway =
        tags['highway']?.toString();

    final type =
        amenity ??
        highway ??
        'reststop';

    final openingHours =
    tags['opening_hours']?.toString();

    final openNow =
    openingHours == null
        ? null
        : isOpenNow(openingHours);

    return RestStop(
      id:
          '${element['type']}${element['id']}',
      name: name,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distance,
      rating: null,
      openNow: openNow,
      openingHours: openingHours,
      address: buildAddress(tags),
      type: type,
    );
  }

  bool? isOpenNow(String openingHours) {
  final value = openingHours.trim();

  if (value.isEmpty) {
    return null;
  }

  // always open
  if (value == '24/7') {
    return true;
  }
  //  closed
  if (value.toLowerCase() == 'closed' ||
      value.toLowerCase() == 'off') {
    return false;
  }

  final now = DateTime.now();
  if (RegExp(
    r'^\d{1,2}:\d{2}-\d{1,2}:\d{2}$',
  ).hasMatch(value)) {
    return _isTimeRangeOpen(
      value,
      now,
    );
  }

  final rules =
      value.split(';');

  bool? foundApplicableRule;

  for (final rawRule in rules) {
    final rule = rawRule.trim();

    if (rule.isEmpty) {
      continue;
    }

    final result = _evaluateOpeningRule(
      rule,
      now.weekday,
      now,
    );

    if (result != null) {
      foundApplicableRule = result;

      if (result == true) {
        return true;
      }
    }
  }

  return foundApplicableRule;
}

bool _isTimeRangeOpen(
  String value,
  DateTime now,
) {
  final times =
      value.split('-');

  if (times.length != 2) {
    return false;
  }

  final start =
      _parseTime(times[0]);

  final end =
      _parseTime(times[1]);

  if (start == null ||
      end == null) {
    return false;
  }

  final currentMinutes =
      now.hour * 60 +
      now.minute;

  final startMinutes =
      start.hour * 60 +
      start.minute;

  final endMinutes =
      end.hour * 60 +
      end.minute;

  // Nnrmal opening period
  if (endMinutes >= startMinutes) {
    return currentMinutes >= startMinutes &&
        currentMinutes <= endMinutes;
  }

  // overnight
  return currentMinutes >= startMinutes ||
      currentMinutes <= endMinutes;
}

bool? _evaluateOpeningRule(
  String rule,
  int weekday,
  DateTime now,
) {
  final parts =
      rule.split(RegExp(r'\s+'));

  if (parts.length < 2) {
    return null;
  }

  final dayPart =
      parts[0];

  final timePart =
      parts.sublist(1).join(' ');

  if (!_isDayMatched(
    dayPart,
    weekday,
  )) {
    return null;
  }

  final intervals =
      timePart.split(',');

  for (final intervalRaw in intervals) {
    final interval =
        intervalRaw.trim();

    final times =
        interval.split('-');

    if (times.length != 2) {
      continue;
    }

    final start =
        _parseTime(times[0]);

    final end =
        _parseTime(times[1]);

    if (start == null ||
        end == null) {
      continue;
    }

    final currentMinutes =
        now.hour * 60 +
        now.minute;

    final startMinutes =
        start.hour * 60 +
        start.minute;

    final endMinutes =
        end.hour * 60 +
        end.minute;

    // Normal interval
    if (endMinutes >= startMinutes) {
      if (currentMinutes >= startMinutes &&
          currentMinutes <= endMinutes) {
        return true;
      }
    }

    // Overnight interval, e.g. 18:00-02:00
    else {
      if (currentMinutes >= startMinutes ||
          currentMinutes <= endMinutes) {
        return true;
      }
    }
  }

  return false;
}

bool _isDayMatched(
  String dayPart,
  int weekday,
) {
  const dayNumbers = {
    'Mo': 1,
    'Tu': 2,
    'We': 3,
    'Th': 4,
    'Fr': 5,
    'Sa': 6,
    'Su': 7,
  };

  if (dayPart.contains(',')) {
    final days =
        dayPart.split(',');

    return days.any(
      (day) =>
          dayNumbers[day] == weekday,
    );
  }

  // Mo-Fr
  if (dayPart.contains('-')) {
    final range =
        dayPart.split('-');

    if (range.length != 2) {
      return false;
    }

    final start =
        dayNumbers[range[0]];

    final end =
        dayNumbers[range[1]];

    if (start == null ||
        end == null) {
      return false;
    }

    return weekday >= start &&
        weekday <= end;
  }

  return dayNumbers[dayPart] ==
      weekday;
}

DateTime? _parseTime(
  String value,
) {
  final parts =
      value.trim().split(':');

  if (parts.length != 2) {
    return null;
  }

  final hour =
      int.tryParse(parts[0]);

  final minute =
      int.tryParse(parts[1]);

  if (hour == null ||
      minute == null) {
    return null;
  }

  if (hour < 0 ||
      hour > 23 ||
      minute < 0 ||
      minute > 59) {
    return null;
  }

  final now =
      DateTime.now();

  return DateTime(
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
}

  String? buildAddress(
    Map tags,
  ) {
    final street =
        tags['addr:street']?.toString();

    final houseNumber =
        tags['addr:housenumber']?.toString();

    final city =
        tags['addr:city']?.toString();

    final parts = <String>[];

    if (street != null) {
      parts.add(
        houseNumber == null
            ? street
            : '$street $houseNumber',
      );
    }

    if (city != null) {
      parts.add(city);
    }

    return parts.isEmpty
        ? null
        : parts.join(', ');
  }

  double haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat =
        toRadians(lat2 - lat1);

    final dLon =
        toRadians(lon2 - lon1);

    final rLat1 =
        toRadians(lat1);

    final rLat2 =
        toRadians(lat2);

    final a =
        math.pow(
              math.sin(dLat / 2),
              2,
            ) +
        math.pow(
              math.sin(dLon / 2),
              2,
            ) *
            math.cos(rLat1) *
            math.cos(rLat2);

    final c =
        2 *
        math.atan2(
          math.sqrt(a),
          math.sqrt(1 - a),
        );

    return earthRadiusKm * c;
  }

  double toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}