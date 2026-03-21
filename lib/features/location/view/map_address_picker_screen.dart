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
  double _radius = 5.0; // km

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
        _radius = locationController.radius;
      });
      _updateCameraZoom(_radius);
    } else {
      setState(() {
        _radius = locationController.radius;
      });
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
    _updateCameraZoom(_radius);
  }

  Future<void> _onCameraMove(CameraPosition position) async {
    setState(() {
      _lastMapPosition = position.target;
    });
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
          //not needed currently
          // _buildSearchOverlay(),
          _buildUseCurrentLocationFloating(),
          _buildRadiusSliderOverlay(),
          _buildBottomForm(),
        ],
      ),
    );
  }

  Widget _buildRadiusSliderOverlay() {
    if (_showFullForm) return const SizedBox.shrink();
    return Positioned(
      bottom: 240.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: context.onPrimaryColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: context.isDarkMode ? Colors.black45 : Colors.black12,
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Radius',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_radius.toInt()} km',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.h,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
              ),
              child: Slider(
                value: _radius,
                min: 1,
                max: 50,
                activeColor: context.primaryColor,
                inactiveColor: context.dividerColor,
                onChanged: (val) {
                  setState(() => _radius = val);
                  _updateCameraZoom(val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateCameraZoom(double radius) async {
    final GoogleMapController controller = await _controller.future;

    double zoom;
    if (radius <= 1) {
      zoom = 15.5;
    } else if (radius <= 2)
      zoom = 14.5;
    else if (radius <= 5)
      zoom = 13.2;
    else if (radius <= 10)
      zoom = 12.2;
    else if (radius <= 20)
      zoom = 11.2;
    else if (radius <= 35)
      zoom = 10.2;
    else
      zoom = 9.5;

    controller
        .animateCamera(CameraUpdate.newLatLngZoom(_lastMapPosition, zoom));
  }

  Widget _buildMap() {
    // Calculate initial zoom based on radius
    double initialZoom = 15 - (_radius / 5);
    if (_radius <= 2) {
      initialZoom = 15;
    } else if (_radius <= 5)
      initialZoom = 13.5;
    else if (_radius <= 10)
      initialZoom = 12.5;
    else if (_radius <= 20)
      initialZoom = 11.5;
    else
      initialZoom = 10.5;

    return GoogleMap(
      initialCameraPosition:
          CameraPosition(target: _lastMapPosition, zoom: initialZoom),
      padding: EdgeInsets.only(
        top: 70.h,
        bottom: _showFullForm ? 0 : 350.h,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      circles: {
        Circle(
          circleId: const CircleId('radius_circle'),
          center: _lastMapPosition,
          radius: _radius * 1000, // Convert to meters
          fillColor: Colors.black.withOpacity(0.3),
          strokeColor: Colors.black,
          strokeWidth: 2,
        ),
      },
    );
  }

  Widget _buildMarkerOverlay() {
    if (_showFullForm) return const SizedBox.shrink();
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.only(top: 70.h, bottom: 350.h),
        child: Align(
          alignment: Alignment.center,
          child: FractionalTranslation(
            translation: const Offset(0, -0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: context.textColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Move the pin to adjust your location',
                    style: TextStyle(
                        color: context.reverseTextColor, fontSize: 10.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                Icon(Icons.location_on, color: Colors.black, size: 40.sp),
              ],
            ),
          ),
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
          color: context.onPrimaryColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
                color: context.isDarkMode ? Colors.black45 : Colors.black12,
                blurRadius: 10)
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Icon(Icons.search, color: context.primaryColor),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Search for a new area, locality...',
                style: TextStyle(color: context.subTextColor, fontSize: 14.sp),
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
      bottom: 335.h, // Positioned above the radius slider
      right: 16.w,
      child: InkWell(
        onTap: _getCurrentLocation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: context.onPrimaryColor,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: context.primaryColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: context.isDarkMode ? Colors.black45 : Colors.black12,
                  blurRadius: 4)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.my_location, color: context.primaryColor, size: 20.sp),
              // SizedBox(width: 8.w),
              // Text(
              //   'Use current location',
              //   style: TextStyle(
              //     color: context.primaryColor,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 14.sp,
              //  ),
              // ),
            ],
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
          color: context.onPrimaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
                color: context.isDarkMode ? Colors.black45 : Colors.black12,
                blurRadius: 10,
                spreadRadius: 5)
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
            color: context.onPrimaryColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.dividerColor),
            boxShadow: [BoxShadow(color: context.dividerColor, blurRadius: 5)],
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: context.primaryColor, size: 28.sp),
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
                      style: TextStyle(
                          fontSize: 12.sp, color: context.subTextColor),
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
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold)),
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
              backgroundColor: context.primaryColor,
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
                        color: context.onPrimaryColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
                if (!widget.isPickOnly) ...[
                  SizedBox(width: 8.w),
                  Icon(Icons.keyboard_arrow_right,
                      color: context.onPrimaryColor),
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
                  color: context.primaryColor,
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
          radius: _radius,
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
            style: TextStyle(fontSize: 14.sp, color: context.subTextColor)),
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
            activeColor: context.primaryColor,
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
              color: isSelected
                  ? context.primaryColor.withOpacity(0.1)
                  : context.surfaceColor,
              border: Border.all(
                  color:
                      isSelected ? context.primaryColor : context.dividerColor),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(icons[index],
                    color: isSelected ? context.primaryColor : Colors.grey,
                    size: 16.sp),
                SizedBox(width: 4.w),
                Text(labels[index],
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? context.primaryColor
                            : context.textColor)),
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
          labelStyle: TextStyle(fontSize: 12.sp, color: context.subTextColor),
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
        color: context.isDarkMode
            ? Colors.white10
            : context.dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Area / Sector / Locality *',
                    style: TextStyle(
                        fontSize: 10.sp, color: context.subTextColor)),
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
            child:
                Text('Change', style: TextStyle(color: context.primaryColor)),
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
          backgroundColor: context.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text('Save address',
            style: TextStyle(
                color: context.onPrimaryColor,
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
          radius: _radius,
        );

    ToastService.showSuccessToast(context, 'Address saved successfully');
    Navigator.pop(context);
  }
}
