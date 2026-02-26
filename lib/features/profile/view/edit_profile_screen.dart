import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'John Doe');
  final TextEditingController _locationController =
      TextEditingController(text: 'Pune, Maharashtra');
  final TextEditingController _emailController =
      TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _mobileController =
      TextEditingController(text: '+91 9876987678');
  final TextEditingController _bioController = TextEditingController(
      text:
          'Passionate about sustainability and community. I love to give books and take plants! Always open to new experiences.');

  bool _profileVisibility = true;
  bool _showTradeHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImage(),
                SizedBox(height: 15.h),
                _buildSectionTitle('Personal Information'),
                SizedBox(height: 10.h),
                _buildTextField('Full Name', _nameController),
                _buildTextField('Location', _locationController,
                    icon: Icons.location_on_outlined),
                _buildTextField('Email Address', _emailController,
                    icon: Icons.email_outlined,
                    helperText: 'Used for notifications and account recovery'),
                _buildTextField('Mobile Number', _mobileController,
                    icon: Icons.phone_android_outlined,
                    helperText: 'Changing number requires OTP verification',
                    readOnly: true),
                SizedBox(height: 10.h),
                _buildSectionTitle('Bio'),
                SizedBox(height: 10.h),
                Text(
                  'Tell others about yourself',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.textColor,
                    fontFamily: FontFamily.openSans,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildBioField(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.w, top: 8.h),
                      child: Text(
                        '${_bioController.text.length}/150',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: greyColor,
                            fontFamily: FontFamily.openSans),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildSectionTitle('Profile Visibility'),
                _buildSwitchTile(
                    'Profile Visibility',
                    'Public: Anyone can view your profile.',
                    _profileVisibility,
                    (val) => setState(() => _profileVisibility = val)),
                // _buildSwitchTile(
                //     'Show Ratings',
                //     'Your ratings are visible to others.',
                //     _showRatings,
                //     (val) => setState(() => _showRatings = val)),
                _buildSwitchTile(
                    'Show Trade History',
                    'Your trade history is hidden from others.',
                    _showTradeHistory,
                    (val) => setState(() => _showTradeHistory = val)),
                SizedBox(height: 20.h),
                _buildSectionTitle('Wallet'),
                SizedBox(height: 10.h),
                _buildWalletCard(),
                SizedBox(height: 15.h),
                _buildSectionTitle('Account Actions'),
                SizedBox(height: 10.h),
                _buildActionText(
                    'Deactivate Account',
                    context.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade700),
                _buildActionText('Delete Account', Colors.red),
                SizedBox(height: 100.h),
              ],
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: context.textColor),
      ),
      centerTitle: true,
      title: Text(
        'Edit Profile',
        style: TextStyle(
          color: context.textColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(10),
        child: Divider(height: 1, color: context.dividerColor),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 70.r,
                backgroundImage: const AssetImage('assets/profile1.png'),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: context.isDarkMode
                              ? Colors.black54
                              : Colors.black12,
                          blurRadius: 4)
                    ],
                  ),
                  child:
                      Icon(Icons.camera_alt, color: defoultColor, size: 24.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
              fontFamily: FontFamily.openSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        fontFamily: FontFamily.openSans,
        color: context.textColor,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon, String? helperText, bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14.sp,
                color: greyColor,
                fontFamily: FontFamily.openSans),
          ),
          SizedBox(height: 4.h),
          TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly
                  ? (context.isDarkMode ? Colors.white10 : Colors.grey.shade100)
                  : context.surfaceColor,
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.grey.shade500, size: 20.sp)
                  : null,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: context.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: context.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: defoultColor),
              ),
            ),
          ),
          if (helperText != null) ...[
            SizedBox(height: 4.h),
            Text(
              helperText,
              style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade500,
                  fontFamily: FontFamily.openSans),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _bioController,
            maxLines: 4,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 14.sp,
              color: context.textColor,
              fontFamily: FontFamily.openSans,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(8.w),
              border: InputBorder.none,
              hintText: 'Enter your bio...',
              hintStyle: TextStyle(
                  fontSize: 10.sp,
                  color: context.textColor.withOpacity(0.5),
                  fontFamily: FontFamily.openSans),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                      fontFamily: FontFamily.openSans),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontFamily: FontFamily.openSans),
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
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.dividerColor),
        boxShadow: context.isDarkMode
            ? []
            : [
                BoxShadow(
                    color: greyColorWithOpacity0_4,
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: defoultColor, size: 25.sp),
              SizedBox(width: 8.w),
              Text(
                'Wallet Balance',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '₹120.00',
            style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: context.textColor),
          ),
          SizedBox(height: 4.h),
          Text(
            'Wallet balance cannot be edited',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildActionText(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 30.w),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: FontFamily.openSans),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Positioned(
      bottom: 20.h,
      left: 20.w,
      right: 20.w,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: defoultColor,
          minimumSize: Size(double.infinity, 55.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          elevation: 0,
          shadowColor: defoultColor,
        ),
        child: Text(
          'Save Changes',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: whiteColor,
              fontFamily: FontFamily.openSans),
        ),
      ),
    );
  }
}
