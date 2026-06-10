import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

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
          const SizedBox(height: 16),
          
          _NavItem(
            icon: Icons.dashboard_outlined, 
            activeIcon: Icons.dashboard,
            title: AppLocalizations.of(context)?.home ?? "Dashboard", 
            isSelected: activeIndex == 0,
            onTap: () {
              if (activeIndex != 0) {
                controller.setIndex(0);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              }
            },
          ),
          _NavItem(
            icon: Icons.card_giftcard_outlined, 
            activeIcon: Icons.card_giftcard,
            title: AppLocalizations.of(context)?.give ?? "Give Tools", 
            isSelected: activeIndex == 1,
            onTap: () {
              if (activeIndex != 1) {
                controller.setIndex(1);
                Navigator.pushReplacementNamed(context, AppRoutes.webGive);
              }
            },
          ),
          _NavItem(
            icon: Icons.save_alt_outlined, 
            activeIcon: Icons.save_alt,
            title: AppLocalizations.of(context)?.take ?? "Take Tools", 
            isSelected: activeIndex == 2,
            onTap: () {
              if (activeIndex != 2) {
                controller.setIndex(2);
                Navigator.pushReplacementNamed(context, AppRoutes.webTake);
              }
            },
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline, 
            activeIcon: Icons.chat_bubble,
            title: AppLocalizations.of(context)?.chat ?? "Messages", 
            isSelected: activeIndex == 3,
            onTap: () {
              if (activeIndex != 3) {
                controller.setIndex(3);
                Navigator.pushReplacementNamed(context, AppRoutes.chat);
              }
            },
          ),
          
          const Spacer(),
          const SizedBox(height: 16),
          _NavItem(
            icon: Icons.person_outline, 
            activeIcon: Icons.person,
            title: "My Profile", 
            isSelected: activeIndex == 4,
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

}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? context.primaryColor.withOpacity(0.08) 
                : isHovered 
                    ? Colors.grey.withOpacity(0.05) 
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.isSelected ? widget.activeIcon : widget.icon,
                color: widget.isSelected ? context.primaryColor : (isHovered ? context.textColor : greyColor),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  color: widget.isSelected ? context.primaryColor : (isHovered ? context.textColor : greyColor),
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
