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
import 'package:tool_bocs/features/notifications/view/notifications_screen.dart';
import 'package:tool_bocs/features/profile/view/edit_profile_screen.dart';
import 'package:tool_bocs/features/subscription/view/my_subscriptions_list_screen.dart';
import 'package:tool_bocs/features/trades/view/create_give_Take_post_screen.dart';
import 'package:tool_bocs/features/trades/view/trade_history_screen.dart';
import 'package:tool_bocs/features/profile/view/blocked_users_screen.dart';
import 'package:tool_bocs/features/profile/view/help_support_screen.dart';
import 'package:tool_bocs/features/trades/view/transaction_history_screen.dart';
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

import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (_) => const SplashScreen(),
    AppRoutes.onBoarding: (_) => const OnBoardingScreen(),
    AppRoutes.login: (_) => LoginScreen(),
    AppRoutes.bottomNavBar: (_) => const BottomNavBarScreen(),
    AppRoutes.otp: (_) => const OtpScreen(),
    AppRoutes.home: (_) => const HomeScreen(),
    AppRoutes.chat: (_) => const ChatScreen(),
    AppRoutes.createGivePost: (_) => const CreateGivePostScreen(),
    AppRoutes.signUp: (_) => const SignUpScreen(),
    AppRoutes.productDetails: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        return ProductDetailsScreen(postId: args);
      }
      return const Scaffold(
        body: Center(child: Text('Error: No Post ID provided')),
      );
    },
    AppRoutes.notifications: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        return NotificationsScreen(postId: args);
      }
      return const NotificationsScreen();
    },
    AppRoutes.editProfile: (_) => const EditProfileScreen(),
    AppRoutes.tradeHistory: (_) => const TradeHistoryScreen(),
    AppRoutes.blockedUsers: (_) => const BlockedUsersScreen(),
    AppRoutes.helpSupport: (_) => const HelpSupportScreen(),
    AppRoutes.transactionHistory: (_) => const TransactionHistoryScreen(),
    AppRoutes.tradeStart: (_) => const TradeStartScreen(),
    AppRoutes.tradeOffer: (_) => const TradeOfferScreen(),
    AppRoutes.tradeStep1: (_) => const TradeReturnSearchScreen(),
    AppRoutes.tradeCompletion: (_) => const TradeCompletionScreen(),
    AppRoutes.tradeSuccess: (_) => const TradeSuccessScreen(),
    AppRoutes.tradeDetails: (_) => const TradeDetailsScreen(),
    AppRoutes.termsConditions: (_) => const TermsConditionsScreen(),
    AppRoutes.privacyPolicy: (_) => const PrivacyPolicyScreen(),
    AppRoutes.themeChange: (_) => const ThemeChangeScreen(),
    AppRoutes.noInternet: (_) => const NoInternetScreen(),
    AppRoutes.mySubscription: (_) => const MySubscriptionStatusScreen(),
    AppRoutes.subscriptionHistory: (_) => const MySubscriptionsListScreen(),
    AppRoutes.choosePlan: (_) => const ChoosePlanScreen(),
    AppRoutes.savedUsers: (_) => const SavedUsersScreen(),
  };
}
