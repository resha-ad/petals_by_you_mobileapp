import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  LocationService._();

  static Future<LocationResult> getCurrentLocation() async {
    try {
      return await _doGetLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () => LocationResult.error(
          'Location request timed out. Please enter your address manually.',
        ),
      );
    } catch (e) {
      return LocationResult.error('Failed to get location: $e');
    }
  }

  static Future<LocationResult> _doGetLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult.error(
        'Location services are disabled. Please enable them in Settings.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult.error('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationResult.error(
        'Location permission permanently denied. Enable it in app Settings.',
      );
    }

    // Use medium accuracy — 2–4 s on Android vs 10–30 s for high accuracy.
    late Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } on LocationServiceDisabledException {
      return LocationResult.error('Location services were turned off.');
    } catch (_) {
      // Instant fallback to last known position.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        position = last;
      } else {
        return LocationResult.error(
          'Could not get your location. Please enter it manually.',
        );
      }
    }

    // Reverse-geocode with its own 8-second guard.
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 8));

      if (placemarks.isEmpty) {
        return LocationResult.error('Could not resolve address.');
      }

      final place = placemarks.first;
      final streetParts = [
        place.street,
        place.subLocality,
      ].where((p) => p != null && p.isNotEmpty).toList();

      return LocationResult.success(
        street: streetParts.isNotEmpty
            ? streetParts.join(', ')
            : (place.thoroughfare ?? ''),
        city: place.locality ?? place.subAdministrativeArea ?? '',
        state: place.administrativeArea ?? '',
        zip: place.postalCode ?? '',
        country: place.country ?? 'Nepal',
      );
    } catch (_) {
      return LocationResult.error(
        'Address lookup failed. Please enter your address manually.',
      );
    }
  }
}

class LocationResult {
  final bool isSuccess;
  final String? errorMessage;
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;

  const LocationResult._({
    required this.isSuccess,
    this.errorMessage,
    this.street = '',
    this.city = '',
    this.state = '',
    this.zip = '',
    this.country = 'Nepal',
  });

  factory LocationResult.success({
    required String street,
    required String city,
    required String state,
    required String zip,
    required String country,
  }) => LocationResult._(
    isSuccess: true,
    street: street,
    city: city,
    state: state,
    zip: zip,
    country: country,
  );

  factory LocationResult.error(String message) =>
      LocationResult._(isSuccess: false, errorMessage: message);
}
