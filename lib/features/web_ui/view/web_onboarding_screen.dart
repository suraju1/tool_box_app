import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/splash/controller/on_bording_controller.dart';
import 'package:tool_bocs/features/splash/model/on_bording_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';

class WebOnboardingScreen extends StatefulWidget {
  const WebOnboardingScreen({super.key});

  @override
  State<WebOnboardingScreen> createState() => _WebOnboardingScreenState();
}

class _WebOnboardingScreenState extends State<WebOnboardingScreen> {
  late PageController _pageController;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<OnBoardingController>();
      controller.addListener(_onControllerUpdate);
      controller.fetchOnboardingData();
    });
  }

  void _onControllerUpdate() {
    final controller = context.read<OnBoardingController>();
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

  void _handlingOnPageChanged(int page) {
    context.read<OnBoardingController>().setCurrentPage(page);
  }

  Widget _buildPageIndicator(int count, int currentPage) {
    List<Widget> children = [];
    for (int i = 0; i < count; i++) {
      children.add(
        Container(
          width: i == currentPage ? 24.0 : 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: i == currentPage ? context.primaryColor : context.primaryColor.withOpacity(0.3),
          ),
        ),
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnBoardingController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.onBoardingList.isEmpty) {
          return Scaffold(
            backgroundColor: context.scaffoldBg,
            body: Center(child: CircularProgressIndicator(color: context.primaryColor)),
          );
        }

        if (controller.errorMessage != null && controller.onBoardingList.isEmpty) {
          return Scaffold(
            backgroundColor: context.scaffoldBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Server starting up...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Redirecting to login in 3 seconds...',
                    style: TextStyle(fontSize: 14, color: context.subTextColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _redirectTimer?.cancel();
                          controller.fetchOnboardingData();
                        },
                        child: const Text("Retry"),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          _redirectTimer?.cancel();
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                        child: const Text("Go to Login"),
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
          return Scaffold(
            backgroundColor: context.scaffoldBg,
            body: Center(child: CircularProgressIndicator(color: context.primaryColor)),
          );
        }

        return Scaffold(
          backgroundColor: context.scaffoldBg,
          body: Row(
            children: [
              // Left Pane: Illustration Carousel
              Expanded(
                flex: 1,
                child: Container(
                  color: context.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF0F4FF),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          itemCount: onboardingList.length,
                          controller: _pageController,
                          onPageChanged: _handlingOnPageChanged,
                          itemBuilder: (context, index) {
                            final slide = onboardingList[index];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: slide.imageUrl.startsWith('assets/')
                                      ? Image.asset(slide.imageUrl, height: 400, fit: BoxFit.contain)
                                      : AppCachedImage(
                                          imageUrl: slide.imageUrl,
                                          height: 400.0,
                                          width: 400.0,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                                const SizedBox(height: 32),
                                if (slide.title.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                    child: Text(
                                      slide.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontFamily: FontFamily.openSans,
                                        fontWeight: FontWeight.w700,
                                        color: context.textColor,
                                      ),
                                    ),
                                  ),
                                if (slide.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0, left: 40.0, right: 40.0),
                                    child: Text(
                                      slide.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: context.subTextColor,
                                        fontFamily: FontFamily.openSans,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60.0),
                        child: _buildPageIndicator(onboardingList.length, controller.currentPage),
                      ),
                    ],
                  ),
                ),
              ),

              // Right Pane: Welcome & Action
              Expanded(
                flex: 1,
                child: Container(
                  color: context.surfaceColor,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(bottom: 32),
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo_transperant.png',
                                color: context.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            'Welcome to ToolBocs',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              fontFamily: FontFamily.openSans,
                              color: context.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'The ultimate platform to trade, lend, and borrow tools in your community.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: FontFamily.openSans,
                              color: context.subTextColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 64),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, AppRoutes.login);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontFamily.openSans,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
