import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/web_ui/view/web_location_selection_dialog.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/profile/view/user_profile_screen.dart';
import 'package:tool_bocs/core/services/toast_service.dart';
class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchHomePosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TradeController>();

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PROMOTIONAL BANNER
          if (controller.selectedCategories.isEmpty)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : context.primaryColor,
                      Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey.shade200 
                          : context.primaryColor.withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome to Pro Tools",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Discover and trade the best tools available in your area.",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                              foregroundColor: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : context.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Explore Now",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Graphic placeholder
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Icon(Icons.handyman, size: 100, color: Theme.of(context).brightness == Brightness.dark ? Colors.black12 : Colors.white24),
                  )
                ],
              ),
            ),

          const SizedBox(height: 20),
          _buildLocationHeader(context),
          const SizedBox(height: 20),
          _buildDistanceSection(context),
          const SizedBox(height: 40),

          // CATEGORY OR SECTION TITLE
          Text(
            controller.selectedCategories.isNotEmpty 
                ? "Catalog: ${controller.selectedCategories.first}"
                : "Recommended for You",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // PRODUCTS GRID
          if (controller.isHomeLoading && controller.homePosts.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (controller.homePosts.isEmpty)
            const Center(child: Text("No posts found near you."))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 420,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: controller.homePosts.length,
              itemBuilder: (context, index) {
                return _WebProductCard(post: controller.homePosts[index]);
              },
            ),
        ],
      ),
    ),
  );
}

  Widget _buildLocationHeader(BuildContext context) {
    return Consumer<LocationController>(
      builder: (context, locationController, child) {
        return InkWell(
          onTap: () async {
            await WebLocationSelectionDialog.show(context);
            if (!context.mounted) return;
            context.read<TradeController>().setLocation(
                  locationController.latitude,
                  locationController.longitude,
                );
            context.read<TradeController>().fetchHomePosts();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: greyColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'HOME - ',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: locationController.address ?? 'NA',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).iconTheme.color,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistanceSection(BuildContext context) {
    return Consumer<TradeController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greyColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      padding: EdgeInsets.zero,
                      value: controller.distanceKm,
                      min: 0,
                      max: 50,
                      activeColor: context.primaryColor,
                      inactiveColor: Colors.grey.shade200,
                      thumbColor: context.primaryColor,
                      onChanged: (val) {
                        controller.setDistance(
                          val,
                          triggerFetch: true,
                          fetchType: 'all',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${controller.distanceKm.round()} km',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Distance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.hasLocation
                    ? 'Show items near you'
                    : 'Set your location to enable distance filtering',
                style: TextStyle(
                  fontSize: 12,
                  color: controller.hasLocation ? Colors.grey : Colors.orange,
                  fontWeight: controller.hasLocation
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WebProductCard extends StatelessWidget {
  final PostModel post;
  const _WebProductCard({required this.post});

  Widget _buildExchangeInfo(BuildContext context) {
    final type = post.returnType.toLowerCase().trim();
    final min = post.priceMin;
    final max = post.priceMax;
    final name = post.returnItemName ?? '';
    final category = post.returnItemCategory ?? '';

    if (type == 'exchange' || type == 'item') {
      String text = 'In exchange for: ';
      if (name.isNotEmpty) {
        text += name;
        if (category.isNotEmpty) text += ' ($category)';
      } else if (category.isNotEmpty) {
        text += category;
      } else {
        text += 'Item';
      }
      return Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else if (type == 'free') {
      return Text(
        'Free',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    } else {
      String text = 'In exchange for: ₹${min?.toStringAsFixed(0) ?? 0} (Money)';
      if (min != null && max != null && max != min) {
        text = 'In exchange for: ₹${min.toStringAsFixed(0)} - ₹${max.toStringAsFixed(0)} (Money)';
      }
      return Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildPostMenu(BuildContext context, PostModel post, bool isOwner) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
      ),
      padding: EdgeInsets.zero,
      onSelected: (value) async {
        final profileController = context.read<ProfileController>();
        switch (value) {
          case 'profile':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserProfileScreen(userId: post.userId.toString()),
              ),
            );
            break;
          case 'save':
            final success = await profileController.toggleSaveUser(post.userId);
            if (!context.mounted) return;
            if (success.success) {
              ToastService.showSuccessToast(context, 'User saved successfully');
            } else {
              ToastService.showErrorToast(
                  context, success.message ?? 'Error saving user');
            }
            break;
          case 'share':
            Share.share(
                'Check out ${post.userName}\'s trade: ${post.itemName}\nDownload the app to see more!');
            break;
          case 'hide':
            context.read<TradeController>().hidePost(post.id);
            if (!context.mounted) return;
            ToastService.showSuccessToast(context, 'Post hidden');
            context
                .read<TradeController>()
                .fetchHomePosts(); // Refresh list to remove hidden post
            break;
          case 'block':
            final success = await profileController.blockUser(post.userId);
            if (!context.mounted) return;
            if (success.success) {
              ToastService.showSuccessToast(
                  context, 'User blocked successfully');
              context.read<TradeController>().fetchHomePosts(); // Refresh feed
            } else {
              ToastService.showErrorToast(
                  context, success.message ?? 'Error blocking user');
            }
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          if (!isOwner)
            const PopupMenuItem<String>(
              value: 'profile',
              child: Text('View Seller Profile'),
            ),
          if (!isOwner)
            const PopupMenuItem<String>(
              value: 'save',
              child: Text('Save Seller'),
            ),
          const PopupMenuItem<String>(
            value: 'share',
            child: Text('Share Post'),
          ),
          const PopupMenuItem<String>(
            value: 'hide',
            child: Text('Hide Post'),
          ),
          if (!isOwner)
            const PopupMenuItem<String>(
              value: 'block',
              child: Text('Block User'),
            ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = post.itemImages.isNotEmpty ? post.itemImages.first : '';
    final isTake = post.postType.toLowerCase() == 'take' ||
        post.postType.toLowerCase() == 'taking';
    final authController = context.read<AuthController>();
    final isOwner = authController.currentUser?.id == post.userId;
    final actionLabel = isOwner ? 'Offers' : (isTake ? 'Give' : 'Take');

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: post.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.05) 
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: greyColor.withOpacity(0.1),
                    child: imagePath.isNotEmpty
                        ? AppCachedImage(
                            imageUrl: imagePath,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            radius: 0,
                          )
                        : const Icon(Icons.image_outlined,
                            size: 50, color: Colors.grey),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: post.itemCategory.toLowerCase().contains('goods')
                            ? Colors.blue.shade700
                            : post.itemCategory.toLowerCase().contains('services')
                                ? Colors.green.shade700
                                : post.itemCategory.toLowerCase().contains('money')
                                    ? Colors.orange.shade700
                                    : Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.itemCategory,
                        style: TextStyle(
                          color: (post.itemCategory.toLowerCase().contains('goods') ||
                                  post.itemCategory.toLowerCase().contains('services') ||
                                  post.itemCategory.toLowerCase().contains('money'))
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildPostMenu(context, post, isOwner),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${post.userName}'s ${isTake ? 'Taking' : 'Giving'}",
                          style: TextStyle(color: greyColor, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.distanceKm != null
                                ? '${post.distanceKm!.toStringAsFixed(1)} km away'
                                : '- km away',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          post.itemName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildExchangeInfo(context),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (isOwner) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.notifications,
                              arguments: post.id,
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.productDetails,
                              arguments: post.id,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: Text(actionLabel),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
