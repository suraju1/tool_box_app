import 'package:flutter/material.dart';
import 'package:tool_bocs/core/services/location_service.dart';
import 'package:tool_bocs/core/services/local_location_service.dart';

/// Controller for managing location state
class LocationController extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String? _address;
  String? _city;
  bool _isLoading = false;
  String? _errorMessage;

  // Saved addresses list
  List<Map<String, String>> _savedAddresses = [];

  LocationController() {
    _loadSavedData();
  }

  void _loadSavedData() {
    _savedAddresses = LocalLocationService.loadAddresses();
    final lastLoc = LocalLocationService.loadLastSelectedLocation();
    if (lastLoc != null) {
      _latitude = double.tryParse(lastLoc['lat'] ?? '');
      _longitude = double.tryParse(lastLoc['lng'] ?? '');
      _address = lastLoc['address'];
      _city = lastLoc['city'];
    }
  }

  // Getters
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  String? get city => _city;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLocation => _latitude != null && _longitude != null;
  List<Map<String, String>> get savedAddresses => _savedAddresses;

  /// Fetch current location with address
  Future<bool> fetchLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled. Please enable GPS.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Check/Request permissions
      bool hasPermission = await LocationService.checkPermission();
      if (!hasPermission) {
        hasPermission = await LocationService.requestPermission();
        if (!hasPermission) {
          _errorMessage = 'Location permissions are denied.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // 3. Fetch location
      final locationData = await LocationService.getLocationWithAddress();

      if (locationData != null) {
        _latitude = locationData['latitude'];
        _longitude = locationData['longitude'];
        _address = locationData['address'];

        // Extract city name
        if (_latitude != null && _longitude != null) {
          _city = await LocationService.getCityFromCoordinates(
            _latitude!,
            _longitude!,
          );

          // Save to Hive
          _persistCurrentLocation();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            'Unable to get location. Please check if your GPS is on and you have internet.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        _errorMessage =
            'Location fetch timed out. Please try again in an open area.';
      } else {
        _errorMessage = 'Error: $e';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update location (refresh)
  Future<bool> updateLocation() async {
    return await fetchLocation();
  }

  /// Clear location data
  void clearLocation() {
    _latitude = null;
    _longitude = null;
    _address = null;
    _city = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set location manually
  void setLocation(double lat, double lng, String address) {
    _latitude = lat;
    _longitude = lng;
    _address = address;

    // Try to get city from manual address or coordinates
    LocationService.getCityFromCoordinates(lat, lng).then((cityName) {
      _city = cityName;
      _persistCurrentLocation();
      notifyListeners();
    });

    _persistCurrentLocation();
    notifyListeners();
  }

  /// Save an address (Home, Work, etc.)
  void saveAddress(String label, String fullAddress, double lat, double lng) {
    _savedAddresses.add({
      'label': label,
      'address': fullAddress,
      'lat': lat.toString(),
      'lng': lng.toString(),
    });
    LocalLocationService.saveAddresses(_savedAddresses);
    notifyListeners();
  }

  void _persistCurrentLocation() {
    LocalLocationService.saveLastSelectedLocation({
      'lat': _latitude.toString(),
      'lng': _longitude.toString(),
      'address': _address ?? '',
      'city': _city ?? '',
    });
  }

  /// Update location from user data (API response)
  Future<void> updateFromUserData({
    required String? lat,
    required String? lng,
    required String? address,
  }) async {
    if (lat == null || lng == null) return;

    try {
      _latitude = double.tryParse(lat);
      _longitude = double.tryParse(lng);
      _address = address;

      // Also try to get city if coordinates are valid
      if (_latitude != null && _longitude != null) {
        _city = await LocationService.getCityFromCoordinates(
          _latitude!,
          _longitude!,
        );
        _persistCurrentLocation();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating location from user data: $e');
    }
  }
}
