import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/controller/shimmer_controller.dart';
import 'package:tool_bocs/features/home/view/home_screen.dart';
import 'package:tool_bocs/features/profile/view/profile_screen.dart';
import 'package:tool_bocs/features/trades/view/give_screen.dart';
import 'package:tool_bocs/features/trades/view/take_screen.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/features/chat/view/chat_list_screen.dart';
import 'package:tool_bocs/features/chat/controller/chat_service.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import '../controller/bottom_navbar_controller.dart';

class BottomNavBarScreen extends StatelessWidget {
  const BottomNavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BottomNavBarController>();

    final List<Widget> screens = [
      const HomeScreen(),
      const GiveScreen(),
      const TakeScreen(),
      const ChatListScreen(),
    ];

    return Scaffold(
      drawer: Drawer(
        width: 1.sw * 0.85,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const ProfileScreen(isTab: false, isDrawer: true),
      ),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: (index) {
          controller.onPageChanged(index);
          // Optional: reset shimmer on page change
          context.read<ShimmerController>().reset();
        },
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: controller.currentIndex,
        onTap: (index) {
          controller.setIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: context.primaryColor,
        unselectedItemColor: greyColor,
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        unselectedLabelStyle:
            TextStyle(fontWeight: FontWeight.normal, fontSize: 12.sp),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/give.svg',
              colorFilter: ColorFilter.mode(greyColor, BlendMode.srcIn),
            ), // Icon(Icons.card_giftcard_outlined),
            activeIcon: SvgPicture.asset(
              'assets/icons/give.svg',
              colorFilter:
                  ColorFilter.mode(context.primaryColor, BlendMode.srcIn),
            ), // Icon(Icons.card_giftcard),
            label: AppLocalizations.of(context)!.give,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/take.svg',
              colorFilter: ColorFilter.mode(greyColor, BlendMode.srcIn),
            ), // Icon(Icons.save_alt_outlined),
            activeIcon: SvgPicture.asset(
              'assets/icons/take.svg',
              colorFilter:
                  ColorFilter.mode(context.primaryColor, BlendMode.srcIn),
            ), // Icon(Icons.save_alt),
            label: AppLocalizations.of(context)!.take,
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<int>(
              stream: ChatService().getTotalUnreadCount(),
              builder: (context, snapshot) {
                int count = snapshot.data ?? 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/chat.svg',
                      colorFilter: ColorFilter.mode(greyColor, BlendMode.srcIn),
                    ),
                    if (count > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color:
                                context.primaryColor, // Blue badge as requested
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.r,
                            minHeight: 16.r,
                          ),
                          child: Center(
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: TextStyle(
                                color: context.onPrimaryColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            activeIcon: StreamBuilder<int>(
              stream: ChatService().getTotalUnreadCount(),
              builder: (context, snapshot) {
                int count = snapshot.data ?? 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/chat.svg',
                      colorFilter: ColorFilter.mode(
                          context.primaryColor, BlendMode.srcIn),
                    ),
                    if (count > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: context.onPrimaryColor, width: 1.5),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.r,
                            minHeight: 16.r,
                          ),
                          child: Center(
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: TextStyle(
                                color: context.onPrimaryColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: AppLocalizations.of(context)!.chat,
          ),
        ],
      ),
    );
  }
}
