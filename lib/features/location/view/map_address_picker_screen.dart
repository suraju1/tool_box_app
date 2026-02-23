import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/core/services/location_service.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class MapAddressPickerScreen extends StatefulWidget {
  final bool isPickOnly;
  const MapAddressPickerScreen({super.key, this.isPickOnly = false});

  @override
  State<MapAddressPickerScreen> createState() => _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState extends State<MapAddressPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _lastMapPosition = const LatLng(18.5204, 73.8567); // Default Pune
  String _currentAddress = "Loading address...";
  bool _isReverseGeocoding = false;

  // Form controllers
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  String _selectedLabel = 'Home';
  String _orderFor = 'Myself';

  // State management for multistep flow
  bool _showFullForm = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final locationController = context.read<LocationController>();
    if (locationController.latitude != null &&
        locationController.longitude != null) {
      setState(() {
        _lastMapPosition =
            LatLng(locationController.latitude!, locationController.longitude!);
        _currentAddress = locationController.address ?? "";
        _areaController.text = _currentAddress;
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final success = await context.read<LocationController>().fetchLocation();
    if (success && mounted) {
      final loc = context.read<LocationController>();
      _updateLocalLocation(LatLng(loc.latitude!, loc.longitude!), loc.address!);
    }
  }

  void _updateLocalLocation(LatLng position, String address) {
    setState(() {
      _lastMapPosition = position;
      _currentAddress = address;
      _areaController.text = address;
    });
    _moveCamera(position);
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  Future<void> _onCameraMove(CameraPosition position) async {
    _lastMapPosition = position.target;
  }

  Future<void> _onCameraIdle() async {
    if (_isReverseGeocoding) return;

    setState(() => _isReverseGeocoding = true);
    try {
      final address = await LocationService.getAddressFromCoordinates(
        _lastMapPosition.latitude,
        _lastMapPosition.longitude,
      );
      if (mounted) {
        setState(() {
          _currentAddress = address ?? "Unknown Address";
          _areaController.text = _currentAddress;
        });
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    } finally {
      if (mounted) setState(() => _isReverseGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add address',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildMarkerOverlay(),
          _buildSearchOverlay(),
          _buildUseCurrentLocationFloating(),
          _buildBottomForm(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _lastMapPosition, zoom: 16),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  Widget _buildMarkerOverlay() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 35.h), // Offset for pin height
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Move the pin to adjust your location',
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
            ),
            SizedBox(height: 8.h),
            Icon(Icons.location_on, color: Colors.black, size: 40.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 10.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Icon(Icons.search, color: defoultColor),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Search for a new area, locality...',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUseCurrentLocationFloating() {
    if (_showFullForm) return const SizedBox.shrink();
    return Positioned(
      bottom: 285.h, // Positioned above the bottom sheet
      left: 0,
      right: 0,
      child: Center(
        child: InkWell(
          onTap: _getCurrentLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: defoultColor.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.my_location, color: defoultColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Use current location',
                  style: TextStyle(
                    color: defoultColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomForm() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5)
          ],
        ),
        child: SingleChildScrollView(
          child: _showFullForm
              ? _buildDetailedAddressForm()
              : _buildConfirmationView(),
        ),
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fiding Products for',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 15.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: defoultColor, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentAddress.split(',').first,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentAddress,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {}, // Handled by map movement mostly
                child: Text('Change',
                    style: TextStyle(
                        color: defoultColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: widget.isPickOnly
                ? _onConfirmLocation
                : () => setState(() => _showFullForm = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: defoultColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    widget.isPickOnly
                        ? 'Confirm Location'
                        : 'Add more address details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
                if (!widget.isPickOnly) ...[
                  SizedBox(width: 8.w),
                  Icon(Icons.keyboard_arrow_right, color: Colors.white),
                ]
              ],
            ),
          ),
        ),
        if (!widget.isPickOnly) ...[
          SizedBox(height: 15.h),
          Center(
            child: InkWell(
              onTap: () {
                // Handle unknown location
              },
              child: Text(
                'I don\'t know the exact location on map',
                style: TextStyle(
                  color: defoultColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),
      ],
    );
  }

  void _onConfirmLocation() {
    context.read<LocationController>().setLocation(
          _lastMapPosition.latitude,
          _lastMapPosition.longitude,
          _currentAddress,
        );
    Navigator.pop(context);
  }

  Widget _buildDetailedAddressForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Enter complete address',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () => setState(() => _showFullForm = false),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildSwitchOption(),
        SizedBox(height: 10.h),
        Text('Save address as *',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
        SizedBox(height: 10.h),
        _buildLabelSelector(),
        SizedBox(height: 20.h),
        _buildTextField('Flat / House no / Building name *', _houseController),
        _buildTextField('Floor (optional)', _floorController),
        _buildLocationDetails(),
        SizedBox(height: 20.h),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildSwitchOption() {
    return SizedBox(
      height: 80.h,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Who you are searching for?',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          const Spacer(),
          Row(
            spacing: 10.w,
            children: [
              _buildRadio('Myself'),
              _buildRadio('Someone else'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadio(String label) {
    return InkWell(
      onTap: () => setState(() => _orderFor = label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: label,
            groupValue: _orderFor,
            activeColor: defoultColor,
            onChanged: (v) => setState(() => _orderFor = v!),
          ),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildLabelSelector() {
    final labels = ['Home', 'Work', 'Hotel', 'Other'];
    final icons = [
      Icons.home_outlined,
      Icons.work_outline,
      Icons.hotel_outlined,
      Icons.location_on_outlined
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(labels.length, (index) {
        final isSelected = _selectedLabel == labels[index];
        return InkWell(
          onTap: () => setState(() => _selectedLabel = labels[index]),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? defoultColor.withOpacity(0.1) : Colors.white,
              border: Border.all(
                  color: isSelected ? defoultColor : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(icons[index],
                    color: isSelected ? defoultColor : Colors.grey,
                    size: 16.sp),
                SizedBox(width: 4.w),
                Text(labels[index],
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected ? defoultColor : Colors.black)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Area / Sector / Locality *',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                Text(
                  _currentAddress,
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {}, // Trigger search
            child: Text('Change', style: TextStyle(color: defoultColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: defoultColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text('Save address',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _onSave() {
    if (_houseController.text.isEmpty) {
      ToastService.showErrorToast(context, 'Please enter house/building name');
      return;
    }

    final fullAddress =
        "${_houseController.text}, ${_floorController.text.isNotEmpty ? "${_floorController.text}, " : ""}$_currentAddress";

    context.read<LocationController>().saveAddress(
          _selectedLabel,
          fullAddress,
          _lastMapPosition.latitude,
          _lastMapPosition.longitude,
        );

    context.read<LocationController>().setLocation(
          _lastMapPosition.latitude,
          _lastMapPosition.longitude,
          fullAddress,
        );

    ToastService.showSuccessToast(context, 'Address saved successfully');
    Navigator.pop(context);
  }
}
