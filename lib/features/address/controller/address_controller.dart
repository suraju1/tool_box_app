import 'package:flutter/material.dart';
import 'package:tool_bocs/core/api/api_response.dart';
import 'package:tool_bocs/features/address/model/address_model.dart';
import 'package:tool_bocs/features/address/service/address_service.dart';

class AddressController extends ChangeNotifier {
  final AddressService _addressService = AddressService();

  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((element) => element.isDefault == 1);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _addressService.fetchMyAddresses();

    if (response.success && response.data != null) {
      _addresses = response.data!;
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResponse<AddressModel>> saveAddress(AddressModel address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _addressService.saveAddress(address);

    if (response.success && response.data != null) {
      // If the new address is marked as default, clear other defaults locally
      if (address.isDefault == 1) {
        // (Optional: fetch again to be safe)
        await fetchAddresses(); 
      } else {
        _addresses.add(response.data!);
      }
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<ApiResponse<AddressModel>> updateAddress(int id, AddressModel address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _addressService.updateAddress(id, address);

    if (response.success) {
      await fetchAddresses(); // Refresh list to reflect changes
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<ApiResponse<AddressModel>> setAsDefault(int id) async {
    try {
      final address = _addresses.firstWhere((e) => e.id == id);
      final updatedAddress = AddressModel(
        id: address.id,
        label: address.label,
        address: address.address,
        latitude: address.latitude,
        longitude: address.longitude,
        isDefault: 1,
      );
      return updateAddress(id, updatedAddress);
    } catch (e) {
      return ApiResponse(success: false, message: 'Address not found');
    }
  }

  Future<ApiResponse<dynamic>> deleteAddress(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _addressService.deleteAddress(id);

    if (response.success) {
      _addresses.removeWhere((element) => element.id == id);
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
