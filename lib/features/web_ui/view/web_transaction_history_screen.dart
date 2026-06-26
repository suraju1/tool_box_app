import 'package:cached_network_image/cached_network_image.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/wallet_controller.dart';
import 'package:tool_bocs/features/trades/model/wallet_history_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/features/web_ui/widgets/web_screen_header.dart';

class WebTransactionHistoryScreen extends StatefulWidget {
  const WebTransactionHistoryScreen({super.key});

  @override
  State<WebTransactionHistoryScreen> createState() =>
      _WebTransactionHistoryScreenState();
}

class _WebTransactionHistoryScreenState extends State<WebTransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletController>().fetchWalletHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: const WebScreenHeader(title: 'Transaction History'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Consumer<WalletController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchWalletHistory(),
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.walletHistory.isEmpty) {
                return Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(
                      color: context.textColor.withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchWalletHistory(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: controller.walletHistory.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.walletHistory[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }



  Widget _buildTransactionCard(WalletHistory transaction) {
    final post = transaction.post;
    final imageUrl =
        (post?.images.isNotEmpty ?? false) ? post!.images.first : '';

    // Parse date
    DateTime? date;
    String formattedDate = transaction.deductionDate;
    try {
      date = DateTime.parse(transaction.deductionDate);
      formattedDate =
          DateFormat('dd MMM yyyy • hh:mm a').format(date.toLocal());
    } catch (e) {
      // Use raw string if parsing fails
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (post != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.productDetails,
              arguments: post.id,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.dividerColor),
            boxShadow: context.isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: greyColorWithOpacity0_4,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Post Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: AppCachedImage.getFormattedUrl(imageUrl),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post?.name ?? 'Transaction',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: FontFamily.openSans,
                        color: context.textColor,
                      ),
                    ),
                    if (post?.category != null || post?.type != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (post?.type != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (post!.type.toLowerCase() == 'give' ||
                                        post.type.toLowerCase() == 'giving')
                                    ? const Color(0xFFE3F2FD)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontFamily.openSans,
                                  color: (post.type.toLowerCase() == 'give' ||
                                          post.type.toLowerCase() == 'giving')
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFFE65100),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (post?.category != null)
                            Expanded(
                              child: Text(
                                post!.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: FontFamily.openSans,
                                  color: context.textColor.withOpacity(0.6),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontFamily: FontFamily.openSans,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Text(
                '—₹${transaction.amount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: FontFamily.openSans,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
