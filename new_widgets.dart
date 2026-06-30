  Widget _buildConditionAndSourceBox(PostModel post) {
    if (post.itemCategory.toLowerCase() != 'goods') return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.itemCondition != null && post.itemCondition!.isNotEmpty) ...[
            Row(
              children: [
                Expanded(child: Text('Condition', style: TextStyle(color: Colors.grey.shade500, fontSize: 14))),
                Expanded(flex: 2, child: Text(post.itemCondition!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.textColor))),
              ],
            ),
            if (post.itemSource != null && post.itemSource!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(color: context.dividerColor.withOpacity(0.5)),
              const SizedBox(height: 16),
            ]
          ],
          if (post.itemSource != null && post.itemSource!.isNotEmpty) ...[
            Row(
              children: [
                Expanded(child: Text('Source', style: TextStyle(color: Colors.grey.shade500, fontSize: 14))),
                Expanded(flex: 2, child: Text(post.itemSource!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.textColor))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductInfoCard(PostModel post, LocationController locationController) {
    List<String> points = post.itemDescription
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (points.length == 1 &&
        post.itemNote.contains('.') &&
        post.itemNote.length > 50) {
      points = post.itemNote
          .split('.')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => '$s.')
          .toList();
    }

    final bool isCompleted = post.status.toLowerCase() == 'completed';
    final authController = context.read<AuthController>();
    final isOwner = authController.currentUser?.id == post.userId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
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
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.descriptionPoints,
            style: TextStyle(
              fontSize: 16,
              color: context.textColor.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textColor.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point.trim(),
                      style: TextStyle(
                        fontSize: 15,
                        color: context.textColor.withOpacity(0.75),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: context.dividerColor.withOpacity(0.5)),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: context.subTextColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  post.distanceKm != null
                      ? '${post.distanceKm!.toStringAsFixed(1)} km away from ${locationController.address ?? 'Current Location'}'
                      : post.pickupArea,
                  style: TextStyle(fontSize: 14, color: context.subTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time_outlined, size: 18, color: context.subTextColor),
              const SizedBox(width: 12),
              Text(
                'Posted ${DateUtil.formatTimeAgo(post.createdAt)}.',
                style: TextStyle(fontSize: 14, color: context.subTextColor),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(AppLocalizations.of(context)!.thisItemIsNoLonger,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            )
          else if (isOwner)
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.notifications,
                arguments: post.id,
              ),
              icon: const Icon(Icons.inbox_rounded),
              label: Text(AppLocalizations.of(context)!.viewOffers),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.isDarkMode ? Colors.white : Colors.black,
                foregroundColor: context.isDarkMode ? Colors.black : Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          else ...[
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.tradeOffer),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.isDarkMode ? Colors.white : Colors.black,
                foregroundColor: context.isDarkMode ? Colors.black : Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: Text('Make Offer (${post.postType.toLowerCase() == 'take' || post.postType.toLowerCase() == 'taking' ? 'Give It' : 'Take It'})'),
            ),
            const SizedBox(height: 12),
            Consumer<ProfileController>(
              builder: (context, profileController, child) {
                final isSaved = profileController.savedUsers.any((user) => user.id == post.userId);
                return OutlinedButton.icon(
                  onPressed: () {
                    SaveToCollectionBottomSheet.show(context, post.userId);
                  },
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 20),
                  label: Text(isSaved ? 'Seller Saved' : 'Save Seller'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: isSaved ? context.primaryColor : (context.isDarkMode ? Colors.white : Colors.black87), width: 1),
                    foregroundColor: isSaved ? context.primaryColor : (context.isDarkMode ? Colors.white : Colors.black87),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReturnItemCard(PostModel post) {
    final bool isPrice = _isPriceReturn(post);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: context.dividerColor.withOpacity(0.5))),
            ),
            child: Text(
              isPrice ? 'Price in return' : 'Item in return',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.textColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPrice) ...[
                  Text(
                    post.priceMax != null && post.priceMax! > post.priceMin! 
                        ? '₹${post.priceMin} - ₹${post.priceMax}'
                        : '₹${post.priceMin}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, fontFamily: FontFamily.openSans, color: context.textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.priceInReturn, style: TextStyle(fontSize: 15, color: context.subTextColor)),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: post.returnItemImages.isNotEmpty 
                            ? AppCachedImage(imageUrl: post.returnItemImages.first, width: 64, height: 64, fit: BoxFit.cover, radius: 0)
                            : Container(width: 64, height: 64, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(AppLocalizations.of(context)!.itemName, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
                                Expanded(flex: 2, child: Text(post.returnItemName ?? '-', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.textColor))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(AppLocalizations.of(context)!.condition, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
                                Expanded(flex: 2, child: Text(post.returnItemCondition ?? '-', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.textColor))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(AppLocalizations.of(context)!.itemSource, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
                                Expanded(flex: 2, child: Text(post.returnItemSource ?? '-', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.textColor))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (post.returnItemDescription != null && post.returnItemDescription!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                    const SizedBox(height: 12),
                    ...post.returnItemDescription!.split('\n').where((l) => l.trim().isNotEmpty).map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(margin: const EdgeInsets.only(top: 6, right: 10), width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
                          Expanded(child: Text(l.trim(), style: TextStyle(color: context.subTextColor, fontSize: 14, height: 1.4))),
                        ],
                      ),
                    )),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
