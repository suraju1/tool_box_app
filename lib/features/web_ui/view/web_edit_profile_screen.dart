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
import 'package:tool_bocs/core/widgets/premium_card.dart';
import 'package:tool_bocs/core/widgets/premium_text_field.dart';
import 'package:tool_bocs/core/widgets/animated_switch.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildDashboardHeader(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: isDesktop 
                          ? _buildDesktopGrid(controller)
                          : _buildMobileLayout(controller),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildStickyActionBar(controller),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileController>().ownProfile?.userDetails;
    
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.8),
            theme.primaryColorDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            left: 24,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              splashRadius: 28,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPremiumProfileImage(),
                const SizedBox(width: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _nameController.text.isNotEmpty ? _nameController.text : (profile?.fullName ?? 'User'),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: FontFamily.openSans,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _locationController.text.isNotEmpty ? _locationController.text : 'No location set',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
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
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: _selectedWebImageBytes != null
                    ? Image.memory(
                        _selectedWebImageBytes!,
                        fit: BoxFit.cover,
                      )
                    : AppCachedImage(
                        imageUrl: user?.image ?? '',
                        userName: user?.fullName ?? '',
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.edit, size: 20, color: Theme.of(context).scaffoldBackgroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopGrid(ProfileController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildPersonalInfoCard(),
              const SizedBox(height: 24),
              _buildContactInfoCard(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildPreferencesCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ProfileController controller) {
    return Column(
      children: [
        _buildPersonalInfoCard(),
        const SizedBox(height: 24),
        _buildContactInfoCard(),
        const SizedBox(height: 24),
        _buildPreferencesCard(),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return PremiumCard(
      title: 'Personal Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PremiumTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PremiumTextField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  hintText: 'DD/MM/YYYY',
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ??
                          DateTime.now().subtract(const Duration(days: 6570)),
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
          const SizedBox(height: 8),
          const Text(
            'Gender',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGenderRadio('Male'),
              const SizedBox(width: 24),
              _buildGenderRadio('Female'),
              const SizedBox(width: 24),
              _buildGenderRadio('Other'),
            ],
          ),
          const SizedBox(height: 24),
          PremiumTextField(
            label: 'Bio',
            controller: _bioController,
            maxLines: 4,
            hintText: 'Tell others about yourself...',
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_bioController.text.length}/150',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return PremiumCard(
      title: 'Contact Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PremiumTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  helperText: 'Used for notifications and recovery',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PremiumTextField(
                  label: 'Mobile Number',
                  controller: _mobileController,
                  icon: Icons.phone_android_outlined,
                  helperText: 'Verified mobile number',
                  readOnly: true,
                ),
              ),
            ],
          ),
          PremiumTextField(
            label: 'Location',
            controller: _locationController,
            icon: Icons.location_on_outlined,
            readOnly: true,
            hintText: 'Pick your location',
            onTap: () {
              WebMapAddressPickerDialog.show(context, isPickOnly: true)
                  .then((_) => _updateLocationFromController());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return PremiumCard(
      title: 'Preferences',
      child: Column(
        children: [
          AnimatedSwitch(
            title: 'Profile Visibility',
            subtitle: 'Public: Anyone can view your profile.',
            value: _profileVisibility,
            onChanged: (val) {
              setState(() {
                _profileVisibility = val;
                _hasUnsavedChanges = true;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1),
          ),
          AnimatedSwitch(
            title: 'Show Trade History',
            subtitle: 'Your trade history is hidden from others.',
            value: _showTradeHistory,
            onChanged: (val) {
              setState(() {
                _showTradeHistory = val;
                _hasUnsavedChanges = true;
              });
            },
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
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                      // Discard changes by popping and reopening or resetting state
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).scaffoldBackgroundColor),
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

  Widget _buildGenderRadio(String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = label;
          _hasUnsavedChanges = true;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: label,
            groupValue: _selectedGender,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (v) {
              setState(() {
                _selectedGender = v;
                _hasUnsavedChanges = true;
              });
            },
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
