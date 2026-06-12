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
import 'package:tool_bocs/core/constants/app_theme.dart';
import 'package:tool_bocs/util/colors.dart';

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

  bool _hasUnsavedChanges = false;

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
        _dobController.text =
            "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";
      } catch (e) {
        debugPrint('Error parsing DOB: $e');
        _dobController.text = profile.dateOfBirth!;
      }
    }
    _isInitialized = profile != null;

    // Add listeners to track unsaved changes
    void markUnsaved() {
      if (!_hasUnsavedChanges) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
    }

    _nameController.addListener(markUnsaved);
    _locationController.addListener(markUnsaved);
    _emailController.addListener(markUnsaved);
    _mobileController.addListener(markUnsaved);
    _dobController.addListener(markUnsaved);
    _bioController.addListener(() {
      setState(() {}); // Rebuild for bio char counter
      markUnsaved();
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
        _hasUnsavedChanges = true;
      });
    }
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
          _hasUnsavedChanges = true;
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
          _dobController.text =
              "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}";
        } catch (e) {
          _dobController.text = profile.dateOfBirth!;
        }
      }
      _isInitialized = true;
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;
    // Main grey background respecting dark mode
    final Color bgColor = context.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // For sticky bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: context.textColor, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Overlapping Stack
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main Card
                      Container(
                        margin: const EdgeInsets.only(top: 80), // Offset for avatar
                        padding: EdgeInsets.fromLTRB(isDesktop ? 64 : 32, isDesktop ? 64 : 100, isDesktop ? 64 : 32, 48),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: context.isDarkMode
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: isDesktop ? _buildDesktopGrid() : _buildMobileLayout(),
                      ),

                      // Avatar & Name Overlay
                      Positioned(
                        top: 0,
                        left: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildPremiumProfileImage(),
                            const SizedBox(width: 24),
                            // Text aligned above the white card
                            Padding(
                              padding: const EdgeInsets.only(bottom: 60),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _nameController.text.isNotEmpty ? _nameController.text : (profile?.fullName ?? 'User'),
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: context.textColor,
                                      fontFamily: FontFamily.openSans,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _locationController.text.isNotEmpty ? _locationController.text : 'No location set',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.subTextColor,
                                      fontFamily: FontFamily.openSans,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildStickyActionBar(controller),
        ],
      ),
    );
  }

  Widget _buildPremiumProfileImage() {
    final user = context.watch<ProfileController>().ownProfile?.userDetails;
    return GestureDetector(
      onTap: _pickImage,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.surfaceColor, width: 6),
                boxShadow: context.isDarkMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.textColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.surfaceColor, width: 2),
                ),
                child: Icon(Icons.edit, size: 14, color: context.scaffoldBg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _buildLeftColumn(),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 5,
          child: _buildRightColumn(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftColumn(),
        const SizedBox(height: 48),
        _buildRightColumn(),
      ],
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Personal Information", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.textColor)),
        const SizedBox(height: 16),
        Divider(color: context.dividerColor, thickness: 1.5),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildModernTextField(
                label: "Full Name",
                controller: _nameController,
                hintText: "Enter full name",
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildModernTextField(
                label: "Date of Birth",
                controller: _dobController,
                hintText: "DD/MM/YYYY",
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
                      _dobController.text =
                          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                      _hasUnsavedChanges = true;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildModernDropdown(
          label: "Gender",
          value: _selectedGender ?? 'Male',
          items: ['Male', 'Female', 'Other'],
          onChanged: (val) {
            setState(() {
              _selectedGender = val;
              _hasUnsavedChanges = true;
            });
          },
        ),
        const SizedBox(height: 24),
        _buildModernTextField(
          label: "Bio",
          controller: _bioController,
          hintText: "Tell others about yourself...",
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Preferences", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.textColor)),
        const SizedBox(height: 16),
        Divider(color: context.dividerColor, thickness: 1.5),
        const SizedBox(height: 32),
        _buildPreferenceBox(
          title: "Profile Visibility",
          subtitle: "Public: Anyone can view your profile.",
          value: _profileVisibility,
          onChanged: (val) {
            setState(() {
              _profileVisibility = val;
              _hasUnsavedChanges = true;
            });
          },
        ),
        _buildPreferenceBox(
          title: "Show Trade History",
          subtitle: "Public: Anyone can view your profile.",
          value: _showTradeHistory,
          onChanged: (val) {
            setState(() {
              _showTradeHistory = val;
              _hasUnsavedChanges = true;
            });
          },
        ),
        const SizedBox(height: 48),
        Text("Contact Information", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.textColor)),
        const SizedBox(height: 16),
        Divider(color: context.dividerColor, thickness: 1.5),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildModernTextField(
                label: "Email Address",
                controller: _emailController,
                hintText: "Email",
                icon: Icons.email_outlined,
                helperText: "Used for notifications and recovery",
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildModernTextField(
                label: "Mobile Number",
                controller: _mobileController,
                hintText: "Mobile",
                icon: Icons.phone_android_outlined,
                helperText: "Verified mobile number",
                readOnly: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildModernTextField(
          label: "Location",
          controller: _locationController,
          hintText: "Pick your location",
          icon: Icons.location_on_outlined,
          readOnly: true,
          onTap: () {
            WebMapAddressPickerDialog.show(context, isPickOnly: true)
                .then((_) => _updateLocationFromController());
          },
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.subTextColor, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: TextStyle(fontSize: 15, color: context.textColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: context.dividerColor, fontSize: 14),
            prefixIcon: icon != null ? Icon(icon, color: context.subTextColor, size: 20) : null,
            filled: true,
            fillColor: context.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.textColor, width: 1.2),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText, style: TextStyle(fontSize: 11, color: context.subTextColor)),
        ]
      ],
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.subTextColor, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, color: context.subTextColor),
          style: TextStyle(fontSize: 15, color: context.textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.textColor, width: 1.2),
            ),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ],
    );
  }

  Widget _buildPreferenceBox({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border.all(color: context.dividerColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textColor)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: context.subTextColor, fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.textColor,
            inactiveThumbColor: context.dividerColor,
            inactiveTrackColor: context.surfaceColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStickyActionBar(ProfileController controller) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: _hasUnsavedChanges ? 0 : -100,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          boxShadow: context.isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  const Text(
                    'You have unsaved changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.isLoading ? null : () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textColor)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: controller.isLoading ? null : () async {
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
                        setState(() {
                          _hasUnsavedChanges = false;
                        });
                        AppSuccessDialog.show(
                          context,
                          message: response.message,
                          onButtonPressed: () {
                            Navigator.pop(context);
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(controller.errorMessage ?? 'Update failed')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.textColor,
                      foregroundColor: context.scaffoldBg,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: context.scaffoldBg),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
