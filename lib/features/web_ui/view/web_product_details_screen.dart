import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/services/share_service.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/util/date_util.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';

class WebProductDetailsScreen extends StatefulWidget {
  final int postId;
  const WebProductDetailsScreen({super.key, required this.postId});

  @override
  State<WebProductDetailsScreen> createState() => _WebProductDetailsScreenState();
}

class _WebProductDetailsScreenState extends State<WebProductDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isHoveringImage = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchPostDetails(widget.postId);
      context.read<ProfileController>().getSavedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _buildAppBar(context),
      body: Consumer2<TradeController, LocationController>(
        builder: (context, controller, locationController, child) {
          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          if (widget.postId == 0) {
            return const Center(
              child: Text('Error: No Post ID provided (or page was refreshed)'),
            );
          }

          if (controller.isLoading || controller.selectedPost?.id != widget.postId) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = controller.selectedPost;
          if (post == null) {
            return const Center(child: Text('Post not found or access denied'));
          }

          // Generate similar posts from already loaded frontend list
          final similarPosts = controller.homePosts
              .where((p) => p.itemCategory == post.itemCategory && p.id != post.id)
              .take(10)
              .toList();

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBreadcrumbs(post),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Media & Details
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildImageGallery(post.itemImages, post.itemCategory),
                                const SizedBox(height: 48),
                                _buildDescriptionSection(post),
                                const SizedBox(height: 48),
                                if (_isPriceReturn(post) || _hasReturnItemDetails(post))
                                  _buildReturnDetailsSection(post),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                          // Right Column: Price, Actions, Seller Info, Specs
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitleAndPriceCard(post, locationController),
                                const SizedBox(height: 24),
                                _buildSellerCard(post),
                                const SizedBox(height: 24),
                                _buildSpecificationsList(post),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      // Bottom Section: Full Width Similar Products
                      if (similarPosts.isNotEmpty)
                        _buildRelatedProducts(similarPosts, post.itemCategory),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: context.textColor,
          size: 20,
        ),
      ),
      centerTitle: true,
      title: Consumer<TradeController>(
        builder: (context, controller, child) {
          return Text(
            controller.selectedPost?.itemName ?? 'Product Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.openSans,
              color: context.textColor,
            ),
          );
        },
      ),
      actions: [
        Consumer<TradeController>(
          builder: (context, controller, child) {
            final post = controller.selectedPost;
            if (post == null) return const SizedBox.shrink();
            return Row(
              children: [
                IconButton(
                  onPressed: _isSharing
                      ? null
                      : () async {
                          setState(() => _isSharing = true);
                          try {
                            await ShareService().sharePost(
                              context,
                              post: post,
                              includeImage: true,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ToastService.showErrorToast(context, 'Unable to share. Try again.');
                          } finally {
                            if (mounted) setState(() => _isSharing = false);
                          }
                        },
                  icon: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share_outlined, color: Colors.grey),
                  tooltip: 'Share',
                ),
                const SizedBox(width: 16),
              ],
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: context.dividerColor),
      ),
    );
  }

  Widget _buildBreadcrumbs(PostModel post) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.bottomNavBar, (route) => false),
          child: Text('Home', style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.w600)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.chevron_right, size: 14, color: Colors.grey),
        ),
        Text(post.itemCategory, style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.w600)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.chevron_right, size: 14, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            post.itemName,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(List<String> images, String category) {
    if (images.isEmpty) {
      return Container(
        height: 600,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.dividerColor),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Hero Image
        MouseRegion(
          onEnter: (_) => setState(() => _isHoveringImage = true),
          onExit: (_) => setState(() => _isHoveringImage = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 600,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: _isHoveringImage ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutQuart,
                    child: AppCachedImage(
                      imageUrl: images[_currentImageIndex],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      radius: 0,
                    ),
                  ),
                  Positioned(
                    top: 24,
                    left: 24,
                    child: _buildCategoryTag(category),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Thumbnail Gallery
        if (images.length > 1)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final isSelected = _currentImageIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentImageIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? context.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: context.primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AppCachedImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        radius: 0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: label.toLowerCase().contains('goods')
            ? Colors.blue.shade700
            : label.toLowerCase().contains('services')
                ? Colors.green.shade700
                : label.toLowerCase().contains('money')
                    ? Colors.orange.shade700
                    : context.isDarkMode
                        ? Colors.white
                        : Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: (label.toLowerCase().contains('goods') ||
                  label.toLowerCase().contains('services') ||
                  label.toLowerCase().contains('money'))
              ? Colors.white
              : context.isDarkMode
                  ? Colors.black
                  : Colors.white,
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(PostModel post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.itemName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            fontFamily: FontFamily.openSans,
            color: context.textColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          post.itemNote.isNotEmpty ? post.itemNote : 'No description provided.',
          style: TextStyle(
            fontSize: 16,
            color: context.textColor.withOpacity(0.75),
            height: 1.8,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndPriceCard(PostModel post, LocationController locationController) {
    final bool isCompleted = post.status.toLowerCase() == 'completed';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.itemName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: FontFamily.openSans,
              color: context.textColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${post.itemCategory} • ${post.itemCondition}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          
          if (_isPriceReturn(post)) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹${post.priceMin}',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    fontFamily: FontFamily.openSans,
                    color: context.textColor,
                  ),
                ),
                if (post.priceMax != null && post.priceMax! > post.priceMin!) ...[
                  const SizedBox(width: 12),
                  Text(
                    '₹${post.priceMax}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ]
              ],
            ),
          ] else ...[
            Text(
              'Exchange Offer',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                fontFamily: FontFamily.openSans,
                color: context.textColor,
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          if (!isCompleted) _buildActionButtons(post),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Center(
                child: Text(
                  'This item is no longer available.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  post.distanceKm != null
                      ? '${post.distanceKm!.toStringAsFixed(1)} km away from ${locationController.address ?? 'Current Location'}'
                      : post.pickupArea,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time_outlined, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(
                'Posted ${DateUtil.formatTimeAgo(post.createdAt)}',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PostModel post) {
    final authController = context.read<AuthController>();
    final isOwner = authController.currentUser?.id == post.userId;

    if (isOwner) {
      return ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications, arguments: post.id),
        icon: const Icon(Icons.inbox_rounded),
        label: const Text('View Offers'),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      );
    }

    final String btnText = (post.postType.toLowerCase() == 'take' || post.postType.toLowerCase() == 'taking') ? 'Give It' : 'Take It';

    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.tradeOffer),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimaryColor,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            elevation: 8,
            shadowColor: context.primaryColor.withOpacity(0.4),
          ),
          child: Text('Make Offer ($btnText)'),
        ),
        const SizedBox(height: 16),
        Consumer<ProfileController>(
          builder: (context, profileController, child) {
            final isSaved = profileController.savedUsers.any((user) => user.id == post.userId);
            return OutlinedButton.icon(
              onPressed: () async {
                final success = await profileController.toggleSaveUser(post.userId);
                if (!context.mounted) return;
                
                if (success.success) {
                  ToastService.showSuccessToast(context, isSaved ? 'Seller removed from saved list' : 'Seller saved successfully');
                } else {
                  ToastService.showErrorToast(context, success.message);
                }
              },
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              label: Text(isSaved ? 'Seller Saved' : 'Save Seller'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: BorderSide(color: isSaved ? context.primaryColor : context.dividerColor, width: 1.5),
                foregroundColor: isSaved ? context.primaryColor : context.textColor,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSellerCard(PostModel post) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUTHORIZED SELLER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => ProfileController.navigateToUserProfile(context, post.userId),
            hoverColor: Colors.transparent,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.dividerColor, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: context.primaryColor.withOpacity(0.1),
                    backgroundImage: post.userImage != null
                        ? NetworkImage(AppCachedImage.getFormattedUrl(post.userImage!)) as ImageProvider
                        : null,
                    child: (post.userImage == null || post.userImage!.isEmpty)
                        ? Text(
                            post.userName.isNotEmpty ? post.userName.substring(0, 1).toUpperCase() : '?',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.primaryColor),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.userName.isNotEmpty ? post.userName : 'User id-${post.userId}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.textColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: Colors.blue, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Member since 2021', // Mock data as per reference
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('142', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: context.textColor)),
                  const SizedBox(height: 8),
                  Text('Listings', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
              Container(width: 1, height: 40, color: context.dividerColor),
              Column(
                children: [
                  Text('${post.userRating?.toStringAsFixed(1) ?? '4.9'}/5', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: context.textColor)),
                  const SizedBox(height: 8),
                  Text('Rating', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsList(PostModel post) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpecRow('Category', post.itemCategory, showTopBorder: false),
          _buildSpecRow('Condition', post.itemCondition),
          _buildSpecRow('Source', post.itemSource),
          _buildSpecRow('Negotiable', post.isNegotiable ? 'Yes' : 'No', showBottomBorder: false),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool showTopBorder = true, bool showBottomBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: showBottomBorder ? BorderSide(color: context.dividerColor.withOpacity(0.5)) : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textColor),
            ),
          ),
        ],
      ),
    );
  }

  bool _isPriceReturn(PostModel post) {
    final type = post.returnType.trim().toLowerCase();
    return type == 'price' || type == 'money' || type == 'cash' || type == 'amount';
  }

  bool _hasReturnItemDetails(PostModel post) {
    return post.returnItemImages.isNotEmpty ||
        (post.returnItemName?.trim().isNotEmpty ?? false) ||
        (post.returnItemCategory?.trim().isNotEmpty ?? false) ||
        (post.returnItemCondition?.trim().isNotEmpty ?? false) ||
        (post.returnItemSource?.trim().isNotEmpty ?? false) ||
        (post.returnItemDescription?.trim().isNotEmpty ?? false);
  }

  Widget _buildReturnDetailsSection(PostModel post) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primaryColor.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          colors: [context.surfaceColor, context.primaryColor.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MARKET VALUE PROJECTION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Expected Return',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _isPriceReturn(post)
                    ? Text(
                        '₹${post.priceMin} — ₹${post.priceMax}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      )
                    : Text(
                        post.returnItemName ?? 'Exchange Item',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          fontFamily: FontFamily.openSans,
                          color: context.textColor,
                        ),
                      ),
              ),
              Icon(Icons.trending_up, color: context.textColor.withOpacity(0.5), size: 32),
            ],
          ),
          if (!_isPriceReturn(post) && _hasReturnItemDetails(post)) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            if (post.returnItemCategory != null && post.returnItemCategory!.isNotEmpty)
              _buildReturnSpecItem('Category', post.returnItemCategory!),
            if (post.returnItemCondition != null && post.returnItemCondition!.isNotEmpty)
              _buildReturnSpecItem('Condition', post.returnItemCondition!),
            if (post.returnItemImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Reference Images:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.returnItemImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openReturnImagePreview(post.returnItemImages, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AppCachedImage(
                          imageUrl: post.returnItemImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildReturnSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label:', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          const SizedBox(width: 12),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.textColor)),
        ],
      ),
    );
  }

  void _openReturnImagePreview(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReturnImagePreviewScreenWeb(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildRelatedProducts(List<PostModel> posts, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'More in $category',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                fontFamily: FontFamily.openSans,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended items from verified sellers.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 420,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 24),
            itemBuilder: (context, index) {
              final item = posts[index];
              return _RelatedProductCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _ReturnImagePreviewScreenWeb extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ReturnImagePreviewScreenWeb({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ReturnImagePreviewScreenWeb> createState() =>
      _ReturnImagePreviewScreenWebState();
}

class _ReturnImagePreviewScreenWebState extends State<_ReturnImagePreviewScreenWeb> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1).toInt();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: SizedBox.expand(
                      child: AppCachedImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.contain,
                        radius: 0,
                        errorWidget: const Center(
                          child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 42),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 24,
              left: 24,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 36),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                top: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RelatedProductCard extends StatefulWidget {
  final PostModel item;
  const _RelatedProductCard({required this.item});

  @override
  State<_RelatedProductCard> createState() => _RelatedProductCardState();
}

class _RelatedProductCardState extends State<_RelatedProductCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebProductDetailsScreen(postId: widget.item.id),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 300,
          transform: Matrix4.translationValues(0, _isHovering ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isHovering ? context.primaryColor.withOpacity(0.3) : context.dividerColor.withOpacity(0.5)),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: widget.item.itemImages.isNotEmpty
                      ? AnimatedScale(
                          scale: _isHovering ? 1.05 : 1.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutQuart,
                          child: AppCachedImage(
                            imageUrl: widget.item.itemImages.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            radius: 0,
                          ),
                        )
                      : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.itemCategory.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: context.primaryColor, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.item.itemName,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: context.textColor, height: 1.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.item.returnType.toLowerCase() == 'price' ? '₹${widget.item.priceMin}' : 'Exchange',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: context.textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
