import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/core/widgets/app_cached_image.dart';
import 'package:tool_bocs/core/widgets/shimmer_box.dart';
import 'package:tool_bocs/features/profile/controller/profile_controller.dart';
import 'package:tool_bocs/features/trades/model/post_model.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/date_util.dart';
import 'package:tool_bocs/features/web_ui/widgets/web_screen_header.dart';

class WebMyPostsScreen extends StatefulWidget {
  final String? initialFilter;
  const WebMyPostsScreen({super.key, this.initialFilter});

  @override
  State<WebMyPostsScreen> createState() => _WebMyPostsScreenState();
}

class _WebMyPostsScreenState extends State<WebMyPostsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFilter != null) {
        context.read<ProfileController>().getMyPosts(
              postType: _getPostTypeFromLabel(widget.initialFilter!),
              label: widget.initialFilter!,
            );
      } else {
        context.read<ProfileController>().getMyPosts();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProfileController>().loadMoreMyPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WebScreenHeader(title: 'My Posts'),
              Expanded(
                child: Consumer<ProfileController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading && controller.myPosts.isEmpty) {
                      return _buildLoadingState();
                    }

                    if (controller.errorMessage != null && controller.myPosts.isEmpty) {
                      return _buildErrorState(controller.errorMessage!, controller);
                    }

                    return RefreshIndicator(
                      onRefresh: () => controller.getMyPosts(
                        postType: _getPostTypeFromLabel(controller.selectedMyPostsFilter),
                        label: controller.selectedMyPostsFilter,
                      ),
                      child: ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          _buildPostSummary(controller),
                          const SizedBox(height: 32),
                          _buildFilters(controller),
                          const SizedBox(height: 24),
                          if (controller.myPosts.isEmpty)
                            _buildEmptyState(context)
                          else ...[
                            _buildPostList(controller),
                            if (controller.isPaginationLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildPostSummary(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Post Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSummaryCard('${controller.totalMyGivesCount}',
                'Total Gives', Icons.outbox_outlined, Colors.red),
            const SizedBox(width: 24),
            _buildSummaryCard('${controller.totalMyTakesCount}',
                'Total Takes', Icons.move_to_inbox_outlined, Colors.orange),
            const SizedBox(width: 24),
            _buildSummaryCard('${controller.totalMyPostsCount}',
                'Total Posts', Icons.handshake, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String count, String label, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: greyColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(width: 12),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(ProfileController controller) {
    return Row(
      children: [
        _buildFilterChip(' All ', controller),
        const SizedBox(width: 12),
        _buildFilterChip(' Gives ', controller),
        const SizedBox(width: 12),
        _buildFilterChip(' Takes ', controller),
      ],
    );
  }

  Widget _buildFilterChip(String label, ProfileController controller) {
    bool isSelected = controller.selectedMyPostsFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        controller.getMyPosts(
          postType: _getPostTypeFromLabel(label),
          label: label,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : Colors.black)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.grey.withOpacity(0.2)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getPostTypeFromLabel(String label) {
    if (label.trim() == 'Gives') return 'give';
    if (label.trim() == 'Takes') return 'take';
    return 'all';
  }

  Widget _buildPostList(ProfileController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 420,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: controller.myPosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(context, controller.myPosts[index]);
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const ShimmerBox(height: 28, width: 200),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 2 ? 24.0 : 0),
                child: const ShimmerBox(height: 120, width: double.infinity, radius: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: const [
            ShimmerBox(height: 48, width: 80, radius: 30),
            SizedBox(width: 12),
            ShimmerBox(height: 48, width: 100, radius: 30),
            SizedBox(width: 12),
            ShimmerBox(height: 48, width: 100, radius: 30),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            mainAxisExtent: 420,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: 6,
          itemBuilder: (context, index) =>
              const ShimmerBox(height: 320, width: double.infinity, radius: 16),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, ProfileController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.getMyPosts(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No posts found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try changing the filter or create a new post!',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createGivePost),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Create Post',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
    final imagePath = post.itemImages.isNotEmpty ? post.itemImages.first : '';
    final isTake = post.postType.toLowerCase() == 'take' ||
        post.postType.toLowerCase() == 'taking';

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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: greyColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Status and Title)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTake ? 'Taking' : 'Giving',
                          style: TextStyle(
                            color: isTake ? Colors.orange : Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.itemName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: context.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(post.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: _getStatusColor(post.status).withOpacity(0.5)),
                    ),
                    child: Text(
                      post.status,
                      style: TextStyle(
                        color: _getStatusColor(post.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Image Section
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border.symmetric(
                          horizontal: BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    child: imagePath.isNotEmpty
                        ? AppCachedImage(
                            imageUrl: imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            radius: 0,
                            errorWidget: Icon(Icons.image_outlined,
                                size: 48, color: Colors.grey.shade400),
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: Icon(Icons.image_outlined,
                                size: 48, color: Colors.grey.shade400),
                          ),
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
                ],
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        DateUtil.formatTimeAgo(post.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.notifications,
                        arguments: post.id,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text(
                      'View Offers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
