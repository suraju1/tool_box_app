import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/features/subscription/controller/subscription_controller.dart';
import 'package:tool_bocs/features/subscription/model/subscription_model.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/web_ui/widgets/web_screen_header.dart';

class WebMySubscriptionStatusScreen extends StatefulWidget {
  const WebMySubscriptionStatusScreen({super.key});

  @override
  State<WebMySubscriptionStatusScreen> createState() =>
      _WebMySubscriptionStatusScreenState();
}

class _WebMySubscriptionStatusScreenState
    extends State<WebMySubscriptionStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionController>().fetchMySubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WebScreenHeader(
        title: 'My Subscription',
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.subscriptionHistory),
              icon: Icon(Icons.history, color: context.primaryColor),
              label: Text('Payment History',
                  style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: context.primaryColor.withOpacity(0.1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SubscriptionController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final subscription = controller.mySubscription;

          if (subscription == null) {
            return _buildEmptyState(context, controller);
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child:
                                _buildCurrentPlanCard(context, subscription)),
                        const SizedBox(width: 32),
                        Expanded(
                            child:
                                _buildCreditStatusCard(context, subscription)),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'INCLUDED BENEFITS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: context.subTextColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 5,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 16,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBenefitItem(
                            context, 'Post Visibility: ${subscription.status}'),
                        _buildBenefitItem(context,
                            'Remaining Days: ${subscription.remainingDays}'),
                        _buildBenefitItem(
                            context, 'Post Price: ₹${subscription.postPrice}'),
                        _buildBenefitItem(context,
                            'Total Allocation: ${subscription.creditBalance} Credits'),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 200,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.choosePlan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Change Plan',
                            style: TextStyle(
                                color: context.reverseTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, SubscriptionController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.subscriptions_outlined,
                  size: 80, color: context.primaryColor),
            ),
            const SizedBox(height: 32),
            Text(
              'No Active Subscription',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.textColor),
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage ??
                  'You don\'t have any active subscription plan.\nChoose a plan to unlock premium features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: context.subTextColor, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 56,
              width: 240,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.choosePlan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View Plans',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => controller.fetchMySubscription(),
              child: Text('Refresh',
                  style: TextStyle(color: context.subTextColor, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(
      BuildContext context, MySubscriptionData subscription) {
    final expiryDate = subscription.endDate.isNotEmpty
        ? DateFormat('dd MMMM yyyy')
            .format(DateTime.parse(subscription.endDate))
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColor,
            context.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.reverseTextColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      subscription.status.toLowerCase() == 'active'
                          ? Icons.check_circle
                          : Icons.warning,
                      size: 16,
                      color: context.reverseTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      subscription.status.toUpperCase(),
                      style: TextStyle(
                        color: context.reverseTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: context.isDarkMode ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${subscription.days} Days Plan',
                  style: TextStyle(
                    color: context.reverseTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Current Plan',
            style: TextStyle(
              fontSize: 16,
              color: context.reverseTextColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${subscription.name} Plan',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: context.reverseTextColor,
              fontFamily: FontFamily.openSans,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.black.withOpacity(0.05) : Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.reverseTextColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.event_available,
                      color: context.reverseTextColor, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expiry Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.reverseTextColor.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expiryDate,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.reverseTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditStatusCard(
      BuildContext context, MySubscriptionData subscription) {
    double usage = 0;
    if (subscription.creditBalance > 0) {
      usage = (double.tryParse(subscription.remainingCredit) ?? 0) /
          subscription.creditBalance;
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.surfaceColor : Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining Credits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usage: ${subscription.usedPosts} posts used',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.subTextColor,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: subscription.remainingCredit.split('.').first,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: context.textColor,
                      ),
                    ),
                    TextSpan(
                      text: '/${subscription.creditBalance}',
                      style: TextStyle(
                        fontSize: 20,
                        color: context.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey.withOpacity(0.3)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                height: 10,
                width: MediaQuery.of(context).size.width *
                    0.3 *
                    (usage > 1 ? 1 : usage),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String benefit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.white10 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
