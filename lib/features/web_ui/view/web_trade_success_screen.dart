import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/subscription/controller/subscription_controller.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/core/widgets/user_review_dialog.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/routes/app_routes.dart';

class WebTradeSuccessScreen extends StatefulWidget {
  const WebTradeSuccessScreen({super.key});

  @override
  State<WebTradeSuccessScreen> createState() => _WebTradeSuccessScreenState();
}

class _WebTradeSuccessScreenState extends State<WebTradeSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showReviewDialog();
    });
  }

  void _showReviewDialog() {
    final tradeController = context.read<TradeController>();
    final authController = context.read<AuthController>();
    final response = tradeController.selectedResponse;
    if (response == null) return;

    final isOwner = authController.currentUser?.id == response.posterUserId;
    final otherUserId = isOwner ? response.responderId : response.posterUserId;
    final otherUserName = isOwner ? response.responderName : response.posterName;

    if (otherUserId != null) {
      showDialog(
        context: context,
        builder: (context) => UserReviewDialog(
          userId: int.tryParse(otherUserId.toString()) ?? 0,
          userName: otherUserName ?? 'User',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tradeController = context.watch<TradeController>();
    final subscriptionController = context.watch<SubscriptionController>();
    final response = tradeController.selectedResponse;
    final posterName = response?.posterName ?? 'the owner';

    final creditFee =
        subscriptionController.mySubscription?.postPrice.split('.').first ??
            tradeController.lastTradeCompletion?.amount.toString() ??
            '5';

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.dividerColor.withOpacity(0.5)),
              boxShadow: context.isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      )
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 100),
                ),
                const SizedBox(height: 48),
                Text(
                  'Trade Confirmed!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    fontFamily: FontFamily.openSans,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your trade request has been sent to $posterName. You can now chat with them to coordinate the handover.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: context.subTextColor,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                if (tradeController.lastTradeCompletion != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.scaffoldBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Trade ID',
                          '#${tradeController.lastTradeCompletion!.tradeId}',
                          context,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Credit',
                          '$creditFee Credits',
                          context,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.tradeDetails),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('View Trade Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.bottomNavBar, (route) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.surfaceColor,
                      side: BorderSide(color: context.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Go to Home', style: TextStyle(color: context.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: context.subTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: context.textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
