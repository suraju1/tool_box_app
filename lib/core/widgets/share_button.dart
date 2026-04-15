import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tool_bocs/core/services/share_service.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/util/colors.dart';

/// A reusable share button widget that triggers sharing for a [PostModel].
///
/// Can be displayed as an icon button (for AppBar / compact areas)
/// or as a full-width button with text.
class ShareButton extends StatefulWidget {
  final PostModel post;
  final bool includeImage;
  final ShareButtonStyle style;

  const ShareButton({
    super.key,
    required this.post,
    this.includeImage = false,
    this.style = ShareButtonStyle.icon,
  });

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  bool _isSharing = false;

  Future<void> _onShare() async {
    if (_isSharing) return; // Prevent double-tap

    setState(() => _isSharing = true);

    try {
      await ShareService().sharePost(
        context,
        post: widget.post,
        includeImage: widget.includeImage,
      );
    } catch (e) {
      if (mounted) {
        ToastService.showErrorToast(context, 'Unable to share. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case ShareButtonStyle.icon:
        return _buildIconButton(context);
      case ShareButtonStyle.iconWithBackground:
        return _buildIconWithBackground(context);
      case ShareButtonStyle.full:
        return _buildFullButton(context);
    }
  }

  /// Compact icon button for AppBar actions.
  Widget _buildIconButton(BuildContext context) {
    return IconButton(
      onPressed: _isSharing ? null : _onShare,
      tooltip: 'Share',
      icon: _isSharing
          ? SizedBox(
              width: 20.sp,
              height: 20.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.textColor,
              ),
            )
          : Icon(
              Icons.share_outlined,
              color: context.textColor,
              size: 22.sp,
            ),
    );
  }

  /// Icon button with a circular background — for overlays or cards.
  Widget _buildIconWithBackground(BuildContext context) {
    return GestureDetector(
      onTap: _isSharing ? null : _onShare,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: context.surfaceColor.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isSharing
            ? SizedBox(
                width: 18.sp,
                height: 18.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.primaryColor,
                ),
              )
            : Icon(
                Icons.share_outlined,
                color: context.primaryColor,
                size: 18.sp,
              ),
      ),
    );
  }

  /// Full-width button with label — for bottom bars or inline placement.
  Widget _buildFullButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isSharing ? null : _onShare,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.surfaceColor,
        foregroundColor: context.primaryColor,
        elevation: 0,
        side: BorderSide(color: context.primaryColor.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        minimumSize: Size(double.infinity, 48.h),
      ),
      icon: _isSharing
          ? SizedBox(
              width: 18.sp,
              height: 18.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.primaryColor,
              ),
            )
          : Icon(Icons.share_outlined, size: 20.sp),
      label: Text(
        _isSharing ? 'Sharing...' : 'Share Post',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Visual style variants for [ShareButton].
enum ShareButtonStyle {
  /// Compact icon button (for AppBar).
  icon,

  /// Icon with circular background (for cards and overlays).
  iconWithBackground,

  /// Full-width button with label.
  full,
}
