import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';
import 'package:tool_bocs/core/controller/theme_controller.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/features/notifications/controller/notification_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class WebHeader extends StatefulWidget {
  const WebHeader({super.key});

  @override
  State<WebHeader> createState() => _WebHeaderState();
}

class _WebHeaderState extends State<WebHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileCtrl = context.read<ProfileController>();
      if (profileCtrl.ownProfile == null) {
        profileCtrl.getUserProfile(null, isOwnProfile: true);
      }
      context.read<NotificationController>().fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<BottomNavBarController>();

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Quote text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                "“Because everything you need is already nearby.”",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: context.textColor.withOpacity(0.8),
                ),
              ),
            ),
          ),

          // Theme Toggle
          Consumer<ThemeController>(
            builder: (context, themeController, child) {
              final isDark = themeController.themeMode == ThemeMode.dark ||
                  (themeController.themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);

              return IconButton(
                onPressed: () {
                  themeController
                      .setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: child.key == const ValueKey('dark')
                          ? Tween<double>(begin: 0.5, end: 1.0)
                              .animate(animation)
                          : Tween<double>(begin: 0.5, end: 1.0)
                              .animate(animation),
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark ? 'light' : 'dark'),
                    color: isDark ? Colors.amber : Colors.grey.shade700,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // Action Icons
          Consumer<NotificationController>(
            builder: (context, notificationCtrl, child) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: notificationCtrl.unreadCount > 0,
                  label: Text('${notificationCtrl.unreadCount}'),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              );
            },
          ),
          const SizedBox(width: 16),
          Container(
            width: 2,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: Consumer2<AuthController, ProfileController>(
              builder: (context, authController, profileController, child) {
                final authUser = authController.currentUser;
                final profileUser = profileController.ownProfile?.userDetails;
                final String userName =
                    profileUser?.fullName ?? authUser?.fullName ?? "User";
                final String? imageUrl = profileUser?.image;

                return Tooltip(
                message: 'Open Profile Menu',
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (context) => const _ProfilePopup(),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: context.primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AppCachedImage(
                              imageUrl: imageUrl ?? '',
                              userName: userName,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              radius: 20,
                              placeholderBgColor:
                                  context.primaryColor.withOpacity(0.1),
                              placeholderTextColor: context.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            userName,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: context.textColor,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePopup extends StatelessWidget {
  const _ProfilePopup();

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final profile = profileController.ownProfile;
    final theme = Theme.of(context);
    final user = profile?.userDetails;

    if (user == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          margin: const EdgeInsets.only(top: 86, right: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                  border: Border.all(color: Colors.grey.shade100, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: AppCachedImage(
                    imageUrl: user.image ?? '',
                    userName: user.fullName,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    radius: 28,
                    placeholderBgColor: theme.primaryColor.withOpacity(0.1),
                    placeholderTextColor: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                user.fullName,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 8),
              // Bio
              Text(
                (user.bio != null && user.bio!.trim().isNotEmpty) 
                    ? user.bio!.trim() 
                    : "Passionate about buying & selling new and used products. Exploring the best deals and connecting with trusted sellers on Trylt Marketplace.",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Instagram
              Row(
                children: [
                  Icon(Icons.mail_outline, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Instagram: @surajubale_1",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Credit Balance
              Row(
                children: [
                  Text(
                    "Credit Balance: ",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    user.remainingBalance ?? '50.00',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

