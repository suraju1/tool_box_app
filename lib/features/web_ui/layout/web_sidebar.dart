import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/routes/app_routes.dart';

class WebSidebar extends StatelessWidget {
  const WebSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BottomNavBarController>();
    final theme = Theme.of(context);
    String? currentRoute = ModalRoute.of(context)?.settings.name;

    int activeIndex = controller.currentIndex;
    if (currentRoute != null) {
      if (currentRoute == AppRoutes.home) {
        activeIndex = 0;
      } else if (currentRoute == AppRoutes.webGive) {
        activeIndex = 1;
      } else if (currentRoute == AppRoutes.webTake) {
        activeIndex = 2;
      } else if (currentRoute == AppRoutes.chat) {
        activeIndex = 3;
      } else if (currentRoute == AppRoutes.webProfile) {
        activeIndex = 4;
      }
      
      if (activeIndex != controller.currentIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.setIndex(activeIndex);
        });
      }
    }

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Image.asset(
              'assets/logo_transperant.png',
              height: 35,
              fit: BoxFit.contain,
              color: context.textColor,
            ),
          ),
          const Divider(),
          
          _buildNavItem(
            context, 
            icon: Icons.dashboard_outlined, 
            activeIcon: Icons.dashboard,
            title: AppLocalizations.of(context)?.home ?? "Dashboard", 
            index: 0, 
            currentIndex: activeIndex,
            onTap: () {
              if (activeIndex != 0) {
                controller.setIndex(0);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              }
            },
          ),
          _buildNavItem(
            context, 
            icon: Icons.card_giftcard_outlined, 
            activeIcon: Icons.card_giftcard,
            title: AppLocalizations.of(context)?.give ?? "Give Tools", 
            index: 1, 
            currentIndex: activeIndex,
            onTap: () {
              if (activeIndex != 1) {
                controller.setIndex(1);
                Navigator.pushReplacementNamed(context, AppRoutes.webGive);
              }
            },
          ),
          _buildNavItem(
            context, 
            icon: Icons.save_alt_outlined, 
            activeIcon: Icons.save_alt,
            title: AppLocalizations.of(context)?.take ?? "Take Tools", 
            index: 2, 
            currentIndex: activeIndex,
            onTap: () {
              if (activeIndex != 2) {
                controller.setIndex(2);
                Navigator.pushReplacementNamed(context, AppRoutes.webTake);
              }
            },
          ),
          _buildNavItem(
            context, 
            icon: Icons.chat_bubble_outline, 
            activeIcon: Icons.chat_bubble,
            title: AppLocalizations.of(context)?.chat ?? "Messages", 
            index: 3, 
            currentIndex: activeIndex,
            onTap: () {
              if (activeIndex != 3) {
                controller.setIndex(3);
                Navigator.pushReplacementNamed(context, AppRoutes.chat);
              }
            },
          ),
          
          const Spacer(),
          const Divider(),
          _buildNavItem(
            context, 
            icon: Icons.person_outline, 
            activeIcon: Icons.person,
            title: "My Profile", 
            index: 4, 
            currentIndex: activeIndex,
            onTap: () {
              if (activeIndex != 4) {
                controller.setIndex(4);
                Navigator.pushReplacementNamed(context, AppRoutes.webProfile);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    bool isSelected = index == currentIndex;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? context.primaryColor : greyColor,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? context.primaryColor : greyColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
