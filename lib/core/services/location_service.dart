import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Service for handling location operations
class LocationService {
  /// Check if location permission is granted
  static Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  static Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current GPS coordinates
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      // Check permission
      bool hasPermission = await checkPermission();
      if (!hasPermission) {
        debugPrint('Location permission not granted. Requesting...');
        hasPermission = await requestPermission();
        if (!hasPermission) {
          debugPrint('Location permission denied after request.');
          return null;
        }
      }

      // Get position
      debugPrint('Fetching position...');

      // 1. Try last known position first (fastest)
      Position? position = await Geolocator.getLastKnownPosition();

      if (position != null) {
        debugPrint(
            'Last known position found: ${position.latitude}, ${position.longitude}');
        return position;
      }

      // 2. Fallback to current position with timeout
      debugPrint('No last known position. Fetching current position...');
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, // High accuracy for precision
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('Location fetch timed out.');
          throw 'Location fetch timed out after 20 seconds';
        },
      );

      debugPrint(
          'Current position fetched: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates using reverse geocoding
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Format address with more precision
        List<String> addressParts = [];

        // Building/Society Name
        if (place.name != null &&
            place.name!.isNotEmpty &&
            place.name != place.locality) {
          addressParts.add(place.name!);
        }

        // Sub-locality (Landmarks/Area)
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        // Street/Thoroughfare
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          addressParts.add(place.thoroughfare!);
        }

        // Locality (City)
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        // State
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        return addressParts.join(', ');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current location with address
  static Future<Map<String, dynamic>?> getLocationWithAddress() async {
    try {
      // Get position
      Position? position = await getCurrentPosition();
      if (position == null) {
        debugPrint('Failed to get GPS position.');
        return null;
      }

      // Get address
      debugPrint('Reverse geocoding coordinates...');
      String? address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (address == null) {
        debugPrint('Reverse geocoding returned null.');
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address ?? 'Location unavailable',
      };
    } catch (e) {
      debugPrint('Error in getLocationWithAddress: $e');
      return null;
    }
  }

  /// Extract city name from address
  static Future<String?> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ?? place.administrativeArea;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
