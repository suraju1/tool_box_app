import 'package:flutter/material.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/features/web_ui/view/web_chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/trade_response_model.dart';
import 'package:tool_bocs/core/api/api_constants.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class WebTradeDetailsScreen extends StatefulWidget {
  final int? tradeId;
  const WebTradeDetailsScreen({super.key, this.tradeId});

  @override
  State<WebTradeDetailsScreen> createState() => _WebTradeDetailsScreenState();
}

class _WebTradeDetailsScreenState extends State<WebTradeDetailsScreen> {
  String? _submittedMark;

  @override
  void initState() {
    super.initState();
    if (widget.tradeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<TradeController>()
            .fetchTradeHistoryDetails(widget.tradeId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tradeController = context.watch<TradeController>();
    final response = tradeController.selectedResponse;
    final isLoading = tradeController.isLoading;

    if (isLoading) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (response == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: _buildAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.noTradeSelected,
                  style: TextStyle(fontSize: 18)),
              if (tradeController.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    tradeController.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: RefreshIndicator(
            onRefresh: () async {
              if (widget.tradeId != null) {
                await context
                    .read<TradeController>()
                    .fetchTradeHistoryDetails(widget.tradeId!);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildChatButtonWeb(context, response),
                      const SizedBox(width: 16),
                      _buildCompleteButtonWeb(context, response),
                      const SizedBox(width: 16),
                      _buildCancelButtonWeb(context, response),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Two Column Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Main Item'),
                            const SizedBox(height: 12),
                            _buildMainItemCard(response),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Exchange Details'),
                            const SizedBox(height: 12),
                            _buildExchangeCard(response),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Trade Notes'),
                            const SizedBox(height: 12),
                            _buildNotesCard(response),
                          ],
                        ),
                      ),

                      const SizedBox(width: 40),

                      // Right Column
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Trade With'),
                            const SizedBox(height: 12),
                            _buildUserCard(response),
                            _buildUserMarkActions(response),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Trade Info'),
                            const SizedBox(height: 12),
                            _buildTradeInfoCard(response),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: context.textColor),
      ),
      title: Text(
        AppLocalizations.of(context)!.tradeDetails,
        style: TextStyle(
          color: context.textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: FontFamily.openSans,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: context.dividerColor.withOpacity(0.5),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        fontFamily: FontFamily.openSans,
        color: context.textColor,
      ),
    );
  }

  // Action Buttons
  Widget _buildCompleteButtonWeb(
      BuildContext context, TradeResponseModel response) {
    final authController = context.read<AuthController>();
    final currentUserId = authController.currentUser?.id;
    final isResponder = currentUserId == response.responderId;

    final canComplete = isResponder &&
        (response.status == 'accepted' || response.status == 'meeting_set');

    if (!canComplete) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: () {
        context.read<TradeController>().setSelectedResponse(response);
        Navigator.pushNamed(context, AppRoutes.tradeCompletion);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
      ),
      child: Text(
        AppLocalizations.of(context)!.completeTrade,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  Widget _buildChatButtonWeb(
      BuildContext context, TradeResponseModel response) {
    final authController = context.read<AuthController>();
    final currentUserId = authController.currentUser?.id;
    final isOwner = currentUserId == response.posterUserId;

    final showChat = response.status == 'accepted' ||
        response.status == 'meeting_set' ||
        response.status == 'paid' ||
        response.status == 'completed';

    if (!showChat) return const SizedBox.shrink();

    return ElevatedButton.icon(
      onPressed: () {
        final otherUserId = isOwner
            ? response.responderId.toString()
            : response.posterUserId.toString();
        final otherUserName =
            isOwner ? response.responderName : (response.posterName ?? 'User');
        final otherUserImage =
            isOwner ? response.responderImage : response.posterImage;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebChatScreen(
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              otherUserImage: otherUserImage,
              tradeResponse: response,
            ),
          ),
        );
      },
      icon: Icon(Icons.chat_bubble_outline,
          color: context.onPrimaryColor, size: 20),
      label: Text(
        'Chat with ${isOwner ? response.responderName : (response.posterName ?? 'User')}',
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.onPrimaryColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
      ),
    );
  }

  Widget _buildCancelButtonWeb(
      BuildContext context, TradeResponseModel response) {
    final authController = context.read<AuthController>();
    final currentUserId = authController.currentUser?.id;

    final isOfferSender = currentUserId == response.responderId;
    final isCancellable = response.status == 'pending' ||
        response.status == 'accepted' ||
        response.status == 'waiting_for_payment';

    if (!isOfferSender || !isCancellable) return const SizedBox.shrink();

    return OutlinedButton(
      onPressed: () => _showCancelConfirmationWeb(context, response.id),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Text(
        AppLocalizations.of(context)!.cancelTrade,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.red),
      ),
    );
  }

  void _showCancelConfirmationWeb(BuildContext context, int tradeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.cancelTrade,
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(AppLocalizations.of(context)!.areYouSureYouWant7,
            style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.no,
                style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await context.read<TradeController>().cancelTrade(tradeId);
              if (mounted) {
                ToastService.showSuccessToast(
                    context,
                    success
                        ? 'Trade cancelled successfully'
                        : 'Failed to cancel trade');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.yesCancel,
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Cards
  Widget _buildMainItemCard(TradeResponseModel response) {
    final itemName =
        response.postItemName ?? response.givingItemName ?? 'Trade Item';
    final images = response.postItemImages.isNotEmpty
        ? response.postItemImages
        : (response.givingItemImages ?? []);
    final imageUrl = images.isNotEmpty ? images.first : '';
    final isGive = response.postType == 'give' || response.postType == 'giving';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageUrl.isNotEmpty
              ? AppCachedImage(
                  imageUrl: imageUrl,
                  width: 120,
                  height: 120,
                  radius: 12,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: context.dividerColor.withOpacity(0.1),
                  ),
                  child:
                      Icon(Icons.image, color: context.dividerColor, size: 40),
                ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: FontFamily.openSans,
                    color: context.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildBadge(
                      isGive ? 'Give' : 'Take',
                      context.isDarkMode
                          ? Colors.blue.withOpacity(0.15)
                          : const Color(0xFFE8F1FF),
                      const Color(0xFF2F80ED),
                    ),
                    const SizedBox(width: 12),
                    _buildBadge(
                      response.status.toUpperCase(),
                      response.status == 'completed'
                          ? (context.isDarkMode
                              ? Colors.green.withOpacity(0.15)
                              : const Color(0xFFE8F9EE))
                          : (context.isDarkMode
                              ? Colors.orange.withOpacity(0.15)
                              : const Color(0xFFFFF4E8)),
                      response.status == 'completed'
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFF2994A),
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

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }

  Widget _buildUserCard(TradeResponseModel response) {
    final authController = context.read<AuthController>();
    final currentUserId = authController.currentUser?.id;

    final isPoster = currentUserId == response.posterUserId;
    final partnerName =
        isPoster ? (response.responderName) : (response.posterName ?? 'Poster');
    final partnerImage = isPoster
        ? (response.responderImage ?? '')
        : (response.posterImage ?? '');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCachedImage(
            imageUrl: partnerImage,
            userName: partnerName,
            width: 100,
            height: 100,
            radius: 50,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Text(
            partnerName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: FontFamily.openSans,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (() {
              final isGive =
                  response.postType == 'give' || response.postType == 'giving';
              final partnerIsGiving =
                  (isPoster && !isGive) || (!isPoster && isGive);
              final itemName =
                  response.postItemName ?? response.givingItemName ?? 'Item';
              return partnerIsGiving
                  ? 'Giving you $itemName'
                  : 'Taking your $itemName';
            })(),
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: context.subTextColor),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                int partnerId =
                    isPoster ? response.responderId : response.posterUserId;
                ProfileController.navigateToUserProfile(context, partnerId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                AppLocalizations.of(context)!.viewProfile,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.onPrimaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMarkActions(TradeResponseModel response) {
    final authController = context.read<AuthController>();
    final currentUserId = authController.currentUser?.id;
    final isCompleted = response.status.toLowerCase() == 'completed';
    final isPoster = currentUserId == response.posterUserId;
    final partnerId = isPoster ? response.responderId : response.posterUserId;

    final tradeController = context.read<TradeController>();
    final existingMark = tradeController.getUserMark(response.id);
    final markFromState = existingMark ?? _submittedMark;

    if (!isCompleted || currentUserId == null || partnerId == 0) {
      return const SizedBox.shrink();
    }

    return Consumer<TradeController>(
      builder: (context, tradeController, _) {
        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                context.isDarkMode ? Colors.white10 : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.dividerColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.rateThisUser,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMarkButtonWeb(
                      label: AppLocalizations.of(context)!.like,
                      icon: Icons.thumb_up_alt_outlined,
                      color: Colors.green,
                      isSelected: markFromState == 'like',
                      isLoading: tradeController.isMarkingUser,
                      onTap: () => _submitUserMark(response, partnerId, 'like'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMarkButtonWeb(
                      label: AppLocalizations.of(context)!.dislike,
                      icon: Icons.thumb_down_alt_outlined,
                      color: Colors.red,
                      isSelected: markFromState == 'dislike',
                      isLoading: tradeController.isMarkingUser,
                      onTap: () =>
                          _submitUserMark(response, partnerId, 'dislike'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarkButtonWeb({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: isSelected ? color : context.dividerColor),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: context.primaryColor),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon,
                        color: isSelected ? Colors.white : color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : context.textColor,
                        fontFamily: FontFamily.openSans,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _submitUserMark(
      TradeResponseModel response, int partnerId, String mark) async {
    final tc = context.read<TradeController>();
    final success = await tc.submitUserMark(
      tradeResponseId: response.id,
      userId: partnerId,
      mark: mark,
    );

    if (!mounted) return;

    if (success) {
      tc.setUserMark(response.id, mark);
      setState(() => _submittedMark = mark);
      ToastService.showSuccessToast(context,
          mark == 'like' ? 'Liked successfully' : 'Disliked successfully');
    } else {
      ToastService.showErrorToast(
          context, tc.errorMessage ?? 'Failed to submit mark');
    }
  }

  Widget _buildExchangeCard(TradeResponseModel response) {
    final authController = context.read<AuthController>();
    final currentUserId = authController.currentUser?.id;
    final isPoster = currentUserId == response.posterUserId;
    final isGive = response.postType == 'give' || response.postType == 'giving';
    final partnerIsGiving = (isPoster && !isGive) || (!isPoster && isGive);

    final isTicketTrade =
        response.responseType == 'price' || response.postReturnType == 'Price';
    String exchangeLabel = partnerIsGiving ? 'You Give' : 'You Receive';
    String exchangeValue =
        response.itemName ?? response.givingItemName ?? 'Item';
    IconData exchangeIcon = Icons.inventory_2_outlined;

    if (isTicketTrade) {
      exchangeLabel = partnerIsGiving ? 'You Pay' : 'You Receive';
      if (response.offerPrice != null && response.offerPrice! > 0) {
        exchangeValue = '₹${response.offerPrice!.toStringAsFixed(0)}';
      } else if (response.priceRangeStart != null) {
        final startPrice = response.priceRangeStart!.toStringAsFixed(0);
        final endPrice = (response.priceRangeEnd ?? response.priceRangeStart!)
            .toStringAsFixed(0);

        if (startPrice == endPrice) {
          exchangeValue = '₹$startPrice';
        } else {
          exchangeValue = '₹$startPrice - ₹$endPrice';
        }
      } else if (response.paymentAmount != null) {
        final parsedAmt =
            double.tryParse(response.paymentAmount!)?.toStringAsFixed(0) ??
                response.paymentAmount;
        exchangeValue = '₹$parsedAmt';
      } else {
        exchangeValue = 'Price';
      }
      exchangeIcon = Icons.currency_rupee;
    }

    final images = response.itemImages.isNotEmpty
        ? response.itemImages
        : (response.givingItemImages ?? []);
    final imageUrl = images.isNotEmpty
        ? (images.first.startsWith('http')
            ? images.first
                .replaceFirst(
                    'http://88.222.245.145:4000', 'https://toolucs.com')
                .replaceFirst('http://', 'https://')
            : '${ApiConstants.baseUrl2}${images.first}')
        : '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  context.isDarkMode ? Colors.white10 : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.dividerColor),
            ),
            child: imageUrl.isNotEmpty && !isTicketTrade
                ? AppCachedImage(
                    imageUrl: imageUrl, fit: BoxFit.cover, radius: 8)
                : Icon(exchangeIcon, color: context.primaryColor, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exchangeLabel,
                    style:
                        TextStyle(fontSize: 16, color: context.subTextColor)),
                const SizedBox(height: 4),
                Text(
                  exchangeValue,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: FontFamily.openSans,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeInfoCard(TradeResponseModel response) {
    String formattedDate = response.createdAt;
    if (formattedDate.contains('T')) {
      formattedDate = formattedDate.split('T').first;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today_outlined, 'Date', formattedDate),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.access_time_outlined, 'Status',
              response.status.toUpperCase()),
          if (response.meetingType != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.handshake_outlined, 'Meeting',
                response.meetingType!.replaceAll('_', ' ').toUpperCase()),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(icon, color: context.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.subTextColor)),
        ),
        Text(text,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: context.textColor)),
      ],
    );
  }

  Widget _buildNotesCard(TradeResponseModel response) {
    String notes = response.itemDescription ?? 'No additional notes provided.';
    if (response.rejectedReason != null) {
      notes = 'Rejected Reason: ${response.rejectedReason}\n\n$notes';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description_outlined,
              color: context.subTextColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: context.subTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
