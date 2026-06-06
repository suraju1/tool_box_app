import 'package:flutter/material.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/view/bottom_navbar_screen.dart';
import 'package:tool_bocs/features/chat/view/chat_screen.dart';
import 'package:tool_bocs/features/home/view/home_screen.dart';
import 'package:tool_bocs/features/login_and_signup/view/login_screen.dart';
import 'package:tool_bocs/features/login_and_signup/view/otp_screen.dart';
import 'package:tool_bocs/features/login_and_signup/view/signup_screen.dart';
import 'package:tool_bocs/features/home/view/product_details_screen.dart';
import 'package:tool_bocs/features/splash/view/onbording_screen.dart';
import 'package:tool_bocs/features/splash/view/splash_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_login_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_onboarding_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_otp_screen.dart';
import 'package:tool_bocs/core/widgets/responsive_layout.dart';
import 'package:tool_bocs/features/notifications/view/notifications_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_notifications_screen.dart';
import 'package:tool_bocs/features/profile/view/edit_profile_screen.dart';
import 'package:tool_bocs/features/subscription/view/my_subscriptions_list_screen.dart';
import 'package:tool_bocs/features/trades/view/create_give_Take_post_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_create_give_take_post_screen.dart';
import 'package:tool_bocs/features/trades/view/trade_history_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_trade_history_screen.dart';
import 'package:tool_bocs/features/profile/view/blocked_users_screen.dart';
import 'package:tool_bocs/features/profile/view/help_support_screen.dart';
import 'package:tool_bocs/features/trades/view/transaction_history_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_trade_offer_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_transaction_history_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_product_details_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_trade_details_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_trade_start_screen.dart';
import 'package:tool_bocs/features/trade_steps_flow/view/trade_start_screen3.dart';
import 'package:tool_bocs/features/trade_steps_flow/view/trade_offer_screen2.dart';
import 'package:tool_bocs/features/trade_steps_flow/view/trade_return_screen1.dart';
import 'package:tool_bocs/features/trade_steps_flow/view/trade_completion_screen4.dart';
import 'package:tool_bocs/features/trade_steps_flow/view/trade_success_screen5.dart';
import 'package:tool_bocs/features/trades/view/trade_details_screen.dart';
import 'package:tool_bocs/features/profile/view/terms_conditions_screen.dart';
import 'package:tool_bocs/features/profile/view/privacy_policy_screen.dart';
import 'package:tool_bocs/features/profile/view/theme_change_screen.dart';
import 'package:tool_bocs/features/network_connectivity/view/no_internet_screen.dart';
import 'package:tool_bocs/features/subscription/view/my_subscription_status_screen.dart';
import 'package:tool_bocs/features/subscription/view/choose_plan_screen.dart';
import 'package:tool_bocs/features/profile/view/saved_users_screen.dart';
import 'package:tool_bocs/features/profile/view/my_posts_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_my_posts_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_saved_users_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_blocked_users_screen.dart';
import 'package:tool_bocs/features/profile/view/setting_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_setting_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_edit_profile_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_help_support_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_terms_conditions_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_privacy_policy_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_home_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_chat_layout.dart';
import 'package:tool_bocs/features/web_ui/view/web_give_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_take_screen.dart';
import 'package:tool_bocs/features/web_ui/view/web_profile_screen.dart';
import 'package:tool_bocs/features/web_ui/layout/web_dashboard_wrapper.dart';
import 'package:tool_bocs/routes/all_reviews_wrapper.dart';
import 'package:tool_bocs/features/profile/model/user_profile_model.dart';
import 'package:tool_bocs/features/shimmer_test/view/shimmer_test_screen.dart';
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (_) => const SplashScreen(),
    AppRoutes.onBoarding: (_) => const ResponsiveLayout(
          mobileScreen: OnBoardingScreen(),
          webScreen: WebOnboardingScreen(),
        ),
    AppRoutes.login: (_) => ResponsiveLayout(
          mobileScreen: LoginScreen(),
          webScreen: const WebLoginScreen(),
        ),
    AppRoutes.bottomNavBar: (_) => const BottomNavBarScreen(),
    AppRoutes.otp: (_) => const ResponsiveLayout(
          mobileScreen: OtpScreen(),
          webScreen: WebOtpScreen(),
        ),
    AppRoutes.home: (_) => const ResponsiveLayout(
          mobileScreen: HomeScreen(),
          webScreen: WebDashboardWrapper(child: WebHomeScreen()),
        ),
    AppRoutes.chat: (_) => const ResponsiveLayout(
          mobileScreen: ChatScreen(),
          webScreen: WebDashboardWrapper(child: WebChatLayout()),
        ),
    AppRoutes.createGivePost: (_) => const ResponsiveLayout(
          mobileScreen: CreateGivePostScreen(),
          webScreen: WebDashboardWrapper(child: WebCreateGivePostScreen()),
        ),
    AppRoutes.signUp: (_) => const SignUpScreen(),
    AppRoutes.productDetails: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final int postId = args is int ? args : 0;
      return ResponsiveLayout(
        mobileScreen: ProductDetailsScreen(postId: postId),
        webScreen: WebDashboardWrapper(child: WebProductDetailsScreen(postId: postId)),
      );
    },
    AppRoutes.notifications: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        return ResponsiveLayout(
          mobileScreen: NotificationsScreen(postId: args),
          webScreen: WebDashboardWrapper(child: WebNotificationsScreen(postId: args)),
        );
      }
      return const ResponsiveLayout(
        mobileScreen: NotificationsScreen(),
        webScreen: WebDashboardWrapper(child: WebNotificationsScreen()),
      );
    },
    AppRoutes.editProfile: (_) => const ResponsiveLayout(
          mobileScreen: EditProfileScreen(),
          webScreen: WebDashboardWrapper(child: WebEditProfileScreen()),
        ),
    AppRoutes.tradeHistory: (_) => const ResponsiveLayout(
          mobileScreen: TradeHistoryScreen(),
          webScreen: WebDashboardWrapper(child: WebTradeHistoryScreen()),
        ),
    AppRoutes.blockedUsers: (_) => const ResponsiveLayout(
          mobileScreen: BlockedUsersScreen(),
          webScreen: WebDashboardWrapper(child: WebBlockedUsersScreen()),
        ),
    AppRoutes.helpSupport: (_) => const ResponsiveLayout(
          mobileScreen: HelpSupportScreen(),
          webScreen: WebDashboardWrapper(child: WebHelpSupportScreen()),
        ),
    AppRoutes.transactionHistory: (_) => const ResponsiveLayout(
          mobileScreen: TransactionHistoryScreen(),
          webScreen: WebDashboardWrapper(child: WebTransactionHistoryScreen()),
        ),
    AppRoutes.tradeStart: (_) => const ResponsiveLayout(
          mobileScreen: TradeStartScreen(),
          webScreen: WebDashboardWrapper(child: WebTradeStartScreen()),
        ),
    AppRoutes.tradeOffer: (_) => const ResponsiveLayout(
          mobileScreen: TradeOfferScreen(),
          webScreen: WebDashboardWrapper(child: WebTradeOfferScreen()),
        ),
    AppRoutes.tradeStep1: (_) => const TradeReturnSearchScreen(),
    AppRoutes.tradeCompletion: (_) => const TradeCompletionScreen(),
    AppRoutes.tradeSuccess: (_) => const TradeSuccessScreen(),
    AppRoutes.tradeDetails: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final int? tradeId = args is int ? args : null;
      return ResponsiveLayout(
        mobileScreen: TradeDetailsScreen(tradeId: tradeId),
        webScreen: WebDashboardWrapper(child: WebTradeDetailsScreen(tradeId: tradeId)),
      );
    },
    AppRoutes.termsConditions: (_) => const ResponsiveLayout(
          mobileScreen: TermsConditionsScreen(),
          webScreen: WebDashboardWrapper(child: WebTermsConditionsScreen()),
        ),
    AppRoutes.privacyPolicy: (_) => const ResponsiveLayout(
          mobileScreen: PrivacyPolicyScreen(),
          webScreen: WebDashboardWrapper(child: WebPrivacyPolicyScreen()),
        ),
    AppRoutes.themeChange: (_) => const ThemeChangeScreen(),
    AppRoutes.noInternet: (_) => const NoInternetScreen(),
    AppRoutes.mySubscription: (_) => const MySubscriptionStatusScreen(),
    AppRoutes.subscriptionHistory: (_) => const MySubscriptionsListScreen(),
    AppRoutes.choosePlan: (_) => const ChoosePlanScreen(),
    AppRoutes.settings: (_) => const ResponsiveLayout(
          mobileScreen: SettingScreen(),
          webScreen: WebDashboardWrapper(child: WebSettingScreen()),
        ),
    AppRoutes.savedUsers: (_) => const ResponsiveLayout(
          mobileScreen: SavedUsersScreen(),
          webScreen: WebDashboardWrapper(child: WebSavedUsersScreen()),
        ),
    AppRoutes.myPosts: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('initialFilter')) {
        return ResponsiveLayout(
          mobileScreen: MyPostsScreen(initialFilter: args['initialFilter']),
          webScreen: WebDashboardWrapper(child: WebMyPostsScreen(initialFilter: args['initialFilter'])),
        );
      }
      return const ResponsiveLayout(
        mobileScreen: MyPostsScreen(),
        webScreen: WebDashboardWrapper(child: WebMyPostsScreen()),
      );
    },
    AppRoutes.allReviews: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return AllReviewsWrapper(
        initialProfile: args is UserProfileModel ? args : null,
      );
    },
    AppRoutes.shimmerTest: (_) => const ShimmerTestScreen(),
    AppRoutes.webGive: (_) => const WebDashboardWrapper(child: WebGiveScreen()),
    AppRoutes.webTake: (_) => const WebDashboardWrapper(child: WebTakeScreen()),
    AppRoutes.webProfile: (_) => const WebDashboardWrapper(child: WebProfileScreen()),
  };
}
