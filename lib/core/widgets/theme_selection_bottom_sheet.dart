import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/theme_controller.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/core/constants/app_theme.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

class ThemeSelectionBottomSheet extends StatefulWidget {
  const ThemeSelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await StorageService.saveFirstuser('visited');
    if (!context.mounted) return;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSelectionBottomSheet(),
    );
  }

  @override
  State<ThemeSelectionBottomSheet> createState() =>
      _ThemeSelectionBottomSheetState();
}

class _ThemeSelectionBottomSheetState extends State<ThemeSelectionBottomSheet> {
  ThemeMode _selectedMode = ThemeMode.system;

  Color get _accentColor {
    if (_selectedMode == ThemeMode.light) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (_selectedMode == ThemeMode.dark) {
      return AppTheme.darkTheme.colorScheme.primary;
    } else {
      return context.primaryColor;
    }
  }

  Color get _onAccentColor {
    if (_selectedMode == ThemeMode.light) {
      return AppTheme.lightTheme.colorScheme.onPrimary;
    } else if (_selectedMode == ThemeMode.dark) {
      return AppTheme.darkTheme.colorScheme.onPrimary;
    } else {
      return context.onPrimaryColor;
    }
  }

  Color get _sheetBgColor {
    if (_selectedMode == ThemeMode.light) {
      return AppTheme.lightTheme.colorScheme.surface;
    } else if (_selectedMode == ThemeMode.dark) {
      return AppTheme.darkTheme.colorScheme.surface;
    } else {
      return context.surfaceColor;
    }
  }

  Color get _textColor {
    if (_selectedMode == ThemeMode.light) {
      return AppTheme.lightTheme.colorScheme.onSurface;
    } else if (_selectedMode == ThemeMode.dark) {
      return AppTheme.darkTheme.colorScheme.onSurface;
    } else {
      return context.textColor;
    }
  }

  Color get _subTextColor {
    if (_selectedMode == ThemeMode.light) {
      return Colors.grey.shade600;
    } else if (_selectedMode == ThemeMode.dark) {
      return Colors.white70;
    } else {
      return context.subTextColor;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedMode = context.read<ThemeController>().themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _sheetBgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: _textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          // Illustration Placeholder
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _textColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                'assets/theme_selection_illustration.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.color_lens_outlined,
                  size: 60.sp,
                  color: _textColor.withOpacity(0.2),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context)!.introducing,
            style: TextStyle(
              color: _accentColor.withOpacity(0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context)!.darkMode,
            style: TextStyle(
              color: _textColor,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              fontFamily: FontFamily.openSans,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            AppLocalizations.of(context)!.chooseYourPreferredAppThemenyou,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _subTextColor,
              fontSize: 14.sp,
              fontFamily: FontFamily.openSans,
            ),
          ),
          SizedBox(height: 30.h),
          _buildOption(AppLocalizations.of(context)!.lightTheme, ThemeMode.light),
          _buildOption(AppLocalizations.of(context)!.darkTheme, ThemeMode.dark),
          _buildOption(AppLocalizations.of(context)!.useDeviceTheme, ThemeMode.system),
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                context.read<ThemeController>().setTheme(_selectedMode);
                StorageService.saveFirstuser('visited');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
                side: _selectedMode == ThemeMode.dark
                    ? const BorderSide(color: Colors.white24)
                    : null,
              ),
              child: Text(
                AppLocalizations.of(context)!.savePreference,
                style: TextStyle(
                  color: _onAccentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildOption(String title, ThemeMode mode) {
    bool isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? _accentColor.withOpacity(0.5) : _textColor.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? _textColor : _textColor.withOpacity(0.6),
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _accentColor : _textColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accentColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
