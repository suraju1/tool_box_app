import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/core/widgets/skeleton_widgets.dart';
import 'package:tool_bocs/features/location/view/location_selection_sheet.dart';
import 'package:tool_bocs/features/notifications/view/notifications_screen.dart';
import 'package:tool_bocs/features/notifications/controller/notification_controller.dart';
import 'package:tool_bocs/features/login_and_signup/controller/auth_controller.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/core/services/storage_service.dart';
import 'package:tool_bocs/core/widgets/theme_selection_bottom_sheet.dart';
import 'package:tool_bocs/util/date_util.dart';
import 'package:tool_bocs/features/profile/view/profile_screen.dart';
import 'package:tool_bocs/features/profile/view/user_profile_screen.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tool_bocs/core/services/toast_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationController = context.read<LocationController>();
      final tradeController = context.read<TradeController>();
      final authController = context.read<AuthController>();

      tradeController.setCurrentUserId(authController.currentUser?.id);

      // Check for first-time user to show theme selection
      final firstUser = await StorageService.getFirstuser();
      if (firstUser == null && mounted) {
        ThemeSelectionBottomSheet.show(context);
      }

      // Reset filters when navigating to this screen
      tradeController.resetFilters();

      // Sync user-selected location (loaded from Hive in LocationController)
      tradeController.setLocation(
        locationController.latitude,
        locationController.longitude,
      );

      tradeController.fetchHomePosts();

      // Fetch unread notification count
      if (mounted) {
        context.read<NotificationController>().fetchUnreadCount();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<TradeController>().loadMoreHomePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.scaffoldBg,
      body: Column(
        children: [
          SizedBox(height: 25.h),
          _buildHeader(context),
          Expanded(
            child: Consumer<TradeController>(
              builder: (context, controller, child) {
                // Proactively sync location from LocationController if it exists but is missing in TradeSontroller
                final locationController = context.read<LocationController>();
                if (locationController.hasLocation && !controller.hasLocation) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.setLocation(
                      locationController.latitude,
                      locationController.longitude,
                    );
                  });
                }

                if (controller.isHomeLoading && controller.homePosts.isEmpty) {
                  return _buildShimmer(context);
                }

                if (controller.errorMessage != null &&
                    controller.homePosts.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.fetchHomePosts(refresh: true);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 200.h),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(controller.errorMessage!),
                              ElevatedButton(
                                onPressed: () => controller.fetchHomePosts(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchHomePosts(refresh: true);
                  },
                  child: Column(
                    children: [
                      Divider(
                        color: context.dividerColor,
                        thickness: 1.h,
                        height: 1.h,
                      ),
                      _buildDistanceSection(context),
                      Divider(
                        color: context.dividerColor,
                        thickness: 1.h,
                        height: 1.h,
                      ),
                      Expanded(
                        child: controller.homePosts.isEmpty &&
                                !controller.isHomeLoading
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: 50.h),
                                  Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.search_off,
                                            size: 64.sp, color: Colors.grey),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'No posts found matching your filters',
                                          style: TextStyle(
                                            color: context.subTextColor,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 8.h),
                                itemCount: controller.homePosts.length +
                                    (controller.isHomeLoadMoreRunning ? 1 : 0),
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 6.h),
                                itemBuilder: (context, index) {
                                  if (index == controller.homePosts.length) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return _buildProductCard(
                                    context,
                                    controller.homePosts[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10.w,
        right: 10.w,
        bottom: 8.h,
      ),
      decoration: BoxDecoration(
        color: context.appBarColor,
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu, color: context.textColor, size: 28.sp),
              ),
              Image.asset(
                'assets/logo_transperant.png',
                height: 35.h,
                fit: BoxFit.contain,
                color: context.textColor,
              ),
              Consumer<NotificationController>(
                builder: (context, notificationController, child) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          color: context.textColor,
                          size: 28.sp,
                        ),
                        if (notificationController.unreadCount > 0)
                          Positioned(
                            right: 0.w,
                            top: 2.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.h),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.h,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                notificationController.unreadCount > 99
                                    ? '99+'
                                    : notificationController.unreadCount
                                        .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Consumer<LocationController>(
            builder: (context, locationController, child) {
              return InkWell(
                onTap: () async {
                  await LocationSelectionSheet.show(context);
                  if (mounted) {
                    context.read<TradeController>().setLocation(
                          locationController.latitude,
                          locationController.longitude,
                        );
                    context.read<TradeController>().fetchHomePosts();
                  }
                },
                child: Row(
                  children: [
                    // Icon(
                    //   Icons.location_on_outlined,
                    //   color: context.textColor,
                    //   size: 20.sp,
                    // ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'HOME - ',
                              style: TextStyle(
                                color: context.textColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 15.sp,
                              ),
                            ),
                            TextSpan(
                              text: '${locationController.address ?? 'NA'}',
                              style: TextStyle(
                                color: context.textColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: context.textColor,
                      size: 22.sp,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // distance section
  Widget _buildDistanceSection(BuildContext context) {
    return Consumer<TradeController>(
      builder: (context, controller, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: context.surfaceColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
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
                  SizedBox(width: 10.w),
                  Text(
                    '${controller.distanceKm.round()} km',
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Text(
                'Distance',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                controller.hasLocation
                    ? 'Show items near you'
                    : 'Set your location to enable distance filtering',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: controller.hasLocation ? greyColor : Colors.orange,
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

  Widget _buildProductCard(BuildContext context, PostModel post) {
    final imagePath = post.itemImages.isNotEmpty ? post.itemImages.first : '';

    // Determine action label based on post type
    // If it's a "give_away" (give), the user can "Take" it.
    // If it's a "taking" (take) request, the user can "Give" it.
    final isTake = post.postType.toLowerCase() == 'take' ||
        post.postType.toLowerCase() == 'taking';
    final authController = context.read<AuthController>();
    final isOwner = authController.currentUser?.id == post.userId;
    final actionLabel = isOwner ? 'Offers' : (isTake ? 'Give' : 'Take');

    // Format exchange details dynamically
    String getExchangeText() {
      final type = post.returnType.toLowerCase().trim();
      final min = post.priceMin;
      final max = post.priceMax;
      final name = post.returnItemName ?? '';
      final category = post.returnItemCategory ?? '';

      if (type == 'price' || type == 'money' || min != null) {
        if (min != null) {
          if (max != null && max != min) {
            return 'In exchange for: ₹${min.toStringAsFixed(0)} - ₹${max.toStringAsFixed(0)} (Money)';
          }
          return 'In exchange for: ₹${min.toStringAsFixed(0)} (Money)';
        }
        return 'In exchange for: Money';
      } else if (type == 'free') {
        return 'In exchange for: Free';
      } else {
        if (name.isNotEmpty) {
          return category.isNotEmpty
              ? 'In exchange for: $name ($category)'
              : 'In exchange for: $name';
        }
        if (category.isNotEmpty) {
          return 'In exchange for: ($category)';
        }
        return 'In exchange for: -';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: post.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.dividerColor),
          boxShadow: context.isDarkMode
              ? []
              : [
                  BoxShadow(
                    color: greyColor.withOpacity(0.4),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${post.userName}'s ${isTake ? 'Taking' : 'Giving'}",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 11.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              post.itemName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: context.primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            post.distanceKm != null
                                ? '${post.distanceKm!.toStringAsFixed(1)} km away'
                                : '- km away',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 11.sp),
                          ),
                          SizedBox(width: 4.w),
                          _buildPostMenu(context, post, isOwner),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 14 / 9,
              child: Container(
                color: Colors.blue.withOpacity(
                  0.1,
                ), // Fixed withValues to withOpacity for compatibility if needed, or keeping withValues if on new Flutter
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imagePath.isNotEmpty
                        ? AppCachedImage(
                            imageUrl: imagePath,
                            fit: BoxFit.contain,
                            width: 1.sw - 44.w,
                            height: (1.sw - 44.w) * 9 / 14,
                            radius: 0,
                            errorWidget: Icon(Icons.image,
                                size: 50.sp, color: Colors.grey),
                          )
                        : Icon(Icons.image, size: 50.sp, color: Colors.grey),
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              post.itemCategory.toLowerCase().contains('goods')
                                  ? Colors.blue.shade700
                                  : post.itemCategory
                                          .toLowerCase()
                                          .contains('services')
                                      ? Colors.green.shade700
                                      : post.itemCategory
                                              .toLowerCase()
                                              .contains('money')
                                          ? Colors.orange.shade700
                                          : context.isDarkMode
                                              ? Colors.white
                                              : Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          post.itemCategory,
                          style: TextStyle(
                            color: (post.itemCategory
                                        .toLowerCase()
                                        .contains('goods') ||
                                    post.itemCategory
                                        .toLowerCase()
                                        .contains('services') ||
                                    post.itemCategory
                                        .toLowerCase()
                                        .contains('money'))
                                ? Colors.white
                                : context.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: FontFamily.openSans,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      getExchangeText(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontFamily: FontFamily.openSans,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () {
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
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 34.w,
                        vertical: 7.h,
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          color: context.onPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Column(
      children: [
        // Distance Section Shimmer
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 18.h, width: 80.w),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: ShimmerBox(height: 20.h, width: double.infinity),
                  ),
                  SizedBox(width: 10.w),
                  ShimmerBox(height: 18.h, width: 40.w),
                ],
              ),
              SizedBox(height: 8.h),
              ShimmerBox(height: 12.h, width: 120.w),
            ],
          ),
        ),
        Divider(color: context.dividerColor, thickness: 1.h, height: 1.h),
        // Product Card Shimmers
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: const ProductCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterPlaceholder(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.trim().isNotEmpty
            ? name.trim().substring(0, 1).toUpperCase()
            : '?',
        style: TextStyle(
          color: context.primaryColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPostMenu(BuildContext context, PostModel post, bool isOwner) {
    return PopupMenuButton<String>(
      color: context.surfaceColor,
      surfaceTintColor: Colors.transparent,
      icon: Icon(Icons.more_vert, color: context.textColor, size: 20.sp),
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
            if (success.success && mounted) {
              ToastService.showSuccessToast(context, 'User saved successfully');
            } else if (mounted) {
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
            if (mounted) {
              ToastService.showSuccessToast(context, 'Post hidden');
              context
                  .read<TradeController>()
                  .fetchHomePosts(); // Refresh list to remove hidden post
            }
            break;
          case 'block':
            final success = await profileController.blockUser(post.userId);
            if (success.success && mounted) {
              ToastService.showSuccessToast(
                  context, 'User blocked successfully');
              context.read<TradeController>().fetchHomePosts(); // Refresh feed
            } else if (mounted) {
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
}

class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({Key? key, required this.text})
      : super(key: key);

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
      child: LayoutBuilder(builder: (context, size) {
        final span = TextSpan(
          text: widget.text,
          style: TextStyle(
            fontSize: 13.sp,
            color: context.textColor,
            fontFamily: FontFamily.openSans,
          ),
        );
        final tp = TextPainter(
          text: span,
          maxLines: 2,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: size.maxWidth);

        if (tp.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                maxLines: isExpanded ? null : 2,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.textColor,
                  fontFamily: FontFamily.openSans,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h, bottom: 2.h),
                  child: Text(
                    isExpanded ? "Show less" : "Read more",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Text(
            widget.text,
            style: TextStyle(
              fontSize: 13.sp,
              color: context.textColor,
              fontFamily: FontFamily.openSans,
            ),
          );
        }
      }),
    );
  }
}
