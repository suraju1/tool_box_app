import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/core/controller/location_controller.dart';
import 'package:tool_bocs/features/web_ui/view/web_location_selection_dialog.dart';
import 'package:tool_bocs/features/web_ui/widgets/web_product_card.dart';
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
      final locationController = context.read<LocationController>();
      final tradeController = context.read<TradeController>();
      
      // Sync user-selected location
      if (locationController.hasLocation) {
        tradeController.setLocation(
          locationController.latitude,
          locationController.longitude,
        );
      }
      
      tradeController.fetchHomePosts();
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
    final locationController = context.watch<LocationController>();
    
    // Proactively sync location from LocationController if it exists but is missing in TradeController
    if (locationController.hasLocation && !controller.hasLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TradeController>().setLocation(
          locationController.latitude,
          locationController.longitude,
        );
      });
    }

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
                return WebProductCard(post: controller.homePosts[index]);
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


