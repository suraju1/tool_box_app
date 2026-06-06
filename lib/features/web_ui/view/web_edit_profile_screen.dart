import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/web_ui/view/web_map_address_picker_dialog.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/widgets/app_success_dialog.dart';
import 'package:tool_bocs/core/widgets/app_image_picker_bs.dart';
import 'package:tool_bocs/util/font_family.dart';

class WebEditProfileScreen extends StatefulWidget {
  const WebEditProfileScreen({super.key});

  @override
  State<WebEditProfileScreen> createState() => _WebEditProfileScreenState();
}

class _WebEditProfileScreenState extends State<WebEditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _bioController;
  late final TextEditingController _dobController;

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _profileVisibility = true;
  bool _showTradeHistory = false;
  XFile? _selectedWebImage;
  Uint8List? _selectedWebImageBytes;
  bool _isInitialized = false;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    final profileCtrl = context.read<ProfileController>();
    if (profileCtrl.ownProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileCtrl.getUserProfile(null, isOwnProfile: true);
      });
    }
    final profile = profileCtrl.ownProfile?.userDetails;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _mobileController = TextEditingController(text: profile?.phoneNumber ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _dobController = TextEditingController(text: profile?.dateOfBirth ?? '');
    _profileVisibility = profile?.profileVisibility == 1;
    _showTradeHistory = profile?.showTradeHistory == 1;
    _selectedGender = profile?.gender;
    _selectedLatitude = _parseCoordinate(profile?.latitude);
    _selectedLongitude = _parseCoordinate(profile?.longitude);
    if (profile?.dateOfBirth != null && profile!.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(profile.dateOfBirth!);
        _dobController.text = "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";
      } catch (e) {
        debugPrint('Error parsing DOB: $e');
        _dobController.text = profile.dateOfBirth!;
      }
    }
    _isInitialized = profile != null;

    _bioController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _pickImage() async {
    final List<XFile>? images = await AppImagePickerBS.show(context);
    if (images != null && images.isNotEmpty) {
      final bytes = await images.first.readAsBytes();
      if (!context.mounted) return;
      setState(() {
        _selectedWebImage = images.first;
        _selectedWebImageBytes = bytes;
      });
    }
  }

  void _viewImageFullScreen(String? imageUrl) {
    if ((imageUrl == null || imageUrl.isEmpty) && _selectedWebImageBytes == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black87),
            ),
            InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: _selectedWebImageBytes != null
                    ? Image.memory(_selectedWebImageBytes!)
                    : AppCachedImage(
                        imageUrl: imageUrl ?? '',
                        userName: '',
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.8,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 36),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  void _updateLocationFromController() {
    final locationController = context.read<LocationController>();
    if (mounted) {
      if (locationController.address != null) {
        setState(() {
          _locationController.text = locationController.address!;
          _selectedLatitude = locationController.latitude;
          _selectedLongitude = locationController.longitude;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final profile = controller.ownProfile?.userDetails;

    if (profile != null && !_isInitialized) {
      _nameController.text = profile.fullName;
      _locationController.text = profile.location ?? '';
      _emailController.text = profile.email ?? '';
      _mobileController.text = profile.phoneNumber ?? '';
      _bioController.text = profile.bio ?? '';
      _dobController.text = profile.dateOfBirth ?? '';
      _profileVisibility = profile.profileVisibility == 1;
      _showTradeHistory = profile.showTradeHistory == 1;
      _selectedGender = profile.gender;
      _selectedLatitude = _parseCoordinate(profile.latitude);
      _selectedLongitude = _parseCoordinate(profile.longitude);
      if (profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(profile.dateOfBirth!);
          _dobController.text = "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";
        } catch (e) {
          _dobController.text = profile.dateOfBirth!;
        }
      }
      _isInitialized = true;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 32),
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Full Name', _nameController, icon: Icons.person_outline)),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTextField(
                                'Location',
                                _locationController,
                                icon: Icons.location_on_outlined,
                                readOnly: true,
                                onTap: () {
                                  WebMapAddressPickerDialog.show(context, isPickOnly: true)
                                      .then((_) => _updateLocationFromController());
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Email Address',
                                _emailController,
                                icon: Icons.email_outlined,
                                helperText: 'Used for notifications and account recovery',
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTextField(
                                'Mobile Number',
                                _mobileController,
                                icon: Icons.phone_android_outlined,
                                helperText: 'Verified mobile number',
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Date of Birth',
                          _dobController,
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _dobController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildGenderRadio('Male'),
                            const SizedBox(width: 16),
                            _buildGenderRadio('Female'),
                            const SizedBox(width: 16),
                            _buildGenderRadio('Other'),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Bio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tell others about yourself',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        _buildBioField(),
                        const SizedBox(height: 32),
                        const Text(
                          'Preferences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchTile(
                          'Profile Visibility',
                          'Public: Anyone can view your profile.',
                          _profileVisibility,
                          (val) => setState(() => _profileVisibility = val),
                        ),
                        const Divider(height: 32),
                        _buildSwitchTile(
                          'Show Trade History',
                          'Your trade history is hidden from others.',
                          _showTradeHistory,
                          (val) => setState(() => _showTradeHistory = val),
                        ),
                        const SizedBox(height: 48),
                        _buildSaveButton(controller),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 24),
            splashRadius: 24,
          ),
          const SizedBox(width: 16),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final user = context.watch<ProfileController>().ownProfile?.userDetails;
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _viewImageFullScreen(user?.image),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: _selectedWebImageBytes != null
                        ? Image.memory(
                            _selectedWebImageBytes!,
                            fit: BoxFit.cover,
                          )
                        : AppCachedImage(
                            imageUrl: user?.image ?? '',
                            userName: user?.fullName ?? '',
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Icon(Icons.camera_alt, size: 20, color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap camera icon to change photo',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon, String? helperText, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).cardColor,
              prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          if (helperText != null) ...[
            const SizedBox(height: 6),
            Text(
              helperText,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
              hintText: 'Enter your bio...',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${_bioController.text.length}/150',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildGenderRadio(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: _selectedGender,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: () async {
                final fullName = _nameController.text.trim();
                if (fullName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Full name is required')),
                  );
                  return;
                }

                final response = await controller.updateProfile(
                  fullName: fullName,
                  location: _locationController.text.trim(),
                  email: _emailController.text.trim(),
                  mobile: _mobileController.text.trim(),
                  bio: _bioController.text.trim(),
                  profileVisibility: _profileVisibility ? 1 : 0,
                  showTradeHistory: _showTradeHistory ? 1 : 0,
                  gender: _selectedGender,
                  dateOfBirth: _selectedDate != null
                      ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                      : null,
                  latitude: _selectedLatitude,
                  longitude: _selectedLongitude,
                  termsAccepted: true,
                  profileImage: _selectedWebImage,
                );

                if (!context.mounted) return;
                if (response.success) {
                  AppSuccessDialog.show(
                    context,
                    message: response.message,
                    onButtonPressed: () {
                      Navigator.pop(context);
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(controller.errorMessage ?? 'Update failed')));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
