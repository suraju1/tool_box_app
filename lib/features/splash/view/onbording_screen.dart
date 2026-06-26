import 'dart:async';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/routes/app_routes.dart';

import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/splash/controller/on_bording_controller.dart';
import 'package:tool_bocs/features/splash/model/on_bording_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    super.initState();
    setScreen();
  }

  setScreen() async {
    Timer(
      const Duration(seconds: 0),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BoardingPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure ScreenUtil.init(...) is called in your app entry (main) before using .w/.h/.sp
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          color: context.scaffoldBg,
          gradient: GradientColors.btnGradient,
        ),
        padding: EdgeInsets.only(top: 50.h),
        child: Center(
          child: Container(
            height: 200.h,
            width: 200.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo_transperant.png',
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BoardingPage extends StatefulWidget {
  const BoardingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BoardingScreenState createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingPage> {
  late PageController _pageController;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Fetch data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<OnBoardingController>();
      // Listen for errors → auto-navigate to login
      controller.addListener(_onControllerUpdate);
      controller.fetchOnboardingData();
    });
  }

  void _onControllerUpdate() {
    final controller = context.read<OnBoardingController>();
    // Only auto-redirect to login if loading is done, there is an error, and the list is empty
    if (!controller.isLoading &&
        controller.errorMessage != null &&
        controller.onBoardingList.isEmpty &&
        mounted) {
      _redirectTimer?.cancel();
      _redirectTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    }
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    final controller = context.read<OnBoardingController>();
    controller.removeListener(_onControllerUpdate);
    _pageController.dispose();
    super.dispose();
  }

  // handling the on page changed
  void _handlingOnPageChanged(int page) {
    context.read<OnBoardingController>().setCurrentPage(page);
  }

  // building page indicator
  Widget _buildPageIndicator(int count, int currentPage) {
    Row row = Row(mainAxisAlignment: MainAxisAlignment.center, children: []);
    for (int i = 0; i < count; i++) {
      row.children.add(_buildPageIndicatorItem(i, currentPage));
      if (i != count - 1) {
        row.children.add(SizedBox(width: 12.w));
      }
    }
    return row;
  }

  Widget _buildPageIndicatorItem(int index, int currentPage) {
    return Container(
      width: index == currentPage ? 10.w : 6.w,
      height: index == currentPage ? 10.w : 6.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == currentPage
            ? context.primaryColor
            : context.primaryColor.withOpacity(0.5),
      ),
    );
  }

  Widget sliderText(OnBoardingModel slide) {
    return Column(
      children: [
        if (slide.title.isNotEmpty) ...[
          SizedBox(height: 0.05.sh),
          SizedBox(
            width: 0.70.sw,
            child: Text(
              slide.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: FontFamily.openSans,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
              //heding Text
            ),
          ),
        ],
        if (slide.description.isNotEmpty) ...[
          SizedBox(height: 0.02.sh),
          SizedBox(
            width: 0.70.sw,
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.subTextColor,
                fontFamily: FontFamily.openSans,
              ),
              //subtext
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnBoardingController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.onBoardingList.isEmpty) {
          return Scaffold(
            backgroundColor: context.scaffoldBg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.errorMessage != null &&
            controller.onBoardingList.isEmpty) {
          return Scaffold(
            backgroundColor: context.scaffoldBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'Server starting up...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Redirecting to login in 3 seconds...',
                    style:
                        TextStyle(fontSize: 13.sp, color: context.subTextColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _redirectTimer?.cancel();
                          controller.fetchOnboardingData();
                        },
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                      SizedBox(width: 12.w),
                      TextButton(
                        onPressed: () {
                          _redirectTimer?.cancel();
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.login);
                        },
                        child: Text(AppLocalizations.of(context)!.goToLogin),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        final onboardingList = controller.onBoardingList;

        if (onboardingList.isEmpty) {
          // Auto-redirect handled by listener; show minimal loading state
          return Scaffold(
            backgroundColor: context.scaffoldBg,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: context.primaryColor,
          body: Stack(
            children: <Widget>[
              PageView.builder(
                itemCount: onboardingList.length,
                controller: _pageController,
                onPageChanged: _handlingOnPageChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final slide = onboardingList[index];
                  return Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: context.scaffoldBg,
                    body: Column(
                      children: <Widget>[
                        Container(
                          height: 0.70.sh,
                          width: 1.sw,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 0.1.sh),
                          padding: EdgeInsets.all(10.w),
                          child: slide.imageUrl.startsWith('assets/')
                              ? Image.asset(slide.imageUrl, fit: BoxFit.cover)
                              : AppCachedImage(
                                  imageUrl: slide.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 0.35.sh,
                  width: 1.sw,
                  margin: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    color: context.scaffoldBg,
                  ),
                  child: Column(
                    children: <Widget>[
                      if (onboardingList.isNotEmpty)
                        sliderText(onboardingList[controller.currentPage]),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontFamily: FontFamily.openSans,
                                fontSize: 17.sp,
                                color: context.primaryColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                          _buildPageIndicator(
                              onboardingList.length, controller.currentPage),
                          TextButton(
                            onPressed: () {
                              controller.currentPage ==
                                      onboardingList.length - 1
                                  ? Navigator.pushNamed(
                                      context, AppRoutes.login)
                                  : _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeIn,
                                    );
                            },
                            child: Text(
                              "Next",
                              style: TextStyle(
                                fontFamily: FontFamily.openSans,
                                fontSize: 17.sp,
                                color: context.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
