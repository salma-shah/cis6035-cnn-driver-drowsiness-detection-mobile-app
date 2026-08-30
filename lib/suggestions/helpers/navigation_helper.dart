import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class NavigationHelper {
  Future<bool> navigateTo({
    required double latitude,
    required double longitude,
    required String label,
  }) async {
    final encodedLabel =
        Uri.encodeComponent(label);
        
    // Android → Google Maps web URL
    // iOS → Apple Maps web URL

    if (Platform.isIOS) {
      final appleMapsUri = Uri.parse(
        'https://maps.apple.com/'
        '?daddr=$latitude,$longitude'
        '&q=$encodedLabel'
        '&dirflg=d',
      );

      try {
        return await launchUrl(
          appleMapsUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }

    final googleMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude'
      '&destination_place_id='
      '&travelmode=driving',
    );

    try {
      return await launchUrl(
        googleMapsUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}

    // if there is no android or ios map, then open street map default

    final osmUri = Uri.parse(
      'https://www.openstreetmap.org/directions'
      '?route=;$latitude,$longitude',
    );

    try {
      return await launchUrl(
        osmUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}

    return false;
  }
}