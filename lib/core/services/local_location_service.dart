import 'package:hive_flutter/hive_flutter.dart';

class LocalLocationService {
  static const String _boxName = 'location_box';
  static const String _savedAddressesKey = 'saved_addresses';
  static const String _lastSelectedLocationKey = 'last_selected_location';

  /// Save the list of addresses to Hive
  static Future<void> saveAddresses(List<Map<String, String>> addresses) async {
    final box = Hive.box(_boxName);
    await box.put(_savedAddressesKey, addresses);
  }

  // Load the list of addresses from Hive
  static List<Map<String, String>> loadAddresses() {
    final box = Hive.box(_boxName);
    final List? data = box.get(_savedAddressesKey);
    if (data == null) return [];

    // Cast to List<Map<String, String>>
    return data.map((item) => Map<String, String>.from(item)).toList();
  }

  /// Save the last selected location (lat, lng, address)
  static Future<void> saveLastSelectedLocation(
      Map<String, String> location) async {
    final box = Hive.box(_boxName);
    await box.put(_lastSelectedLocationKey, location);
  }

  /// Load the last selected location
  static Map<String, String>? loadLastSelectedLocation() {
    final box = Hive.box(_boxName);
    final Map? data = box.get(_lastSelectedLocationKey);
    if (data == null) return null;
    return Map<String, String>.from(data);
  }
}
