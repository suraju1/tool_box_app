import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

class WebFilterDialog extends StatefulWidget {
  final String? initialPostType;
  const WebFilterDialog({super.key, this.initialPostType});

  static Future<void> show(BuildContext context, {String? initialPostType}) {
    return showDialog(
      context: context,
      builder: (context) => WebFilterDialog(initialPostType: initialPostType),
    );
  }

  @override
  State<WebFilterDialog> createState() => _WebFilterDialogState();
}

class _WebFilterDialogState extends State<WebFilterDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TradeController>();
      controller.fetchCategories();
      setState(() {
        distance = controller.distanceKm;
        selectedCategories = List.from(controller.selectedCategories);
        selectedRating = controller.selectedRating;
        returnType = controller.selectedReturnType;
        selectedSort = controller.selectedSort;

        if (widget.initialPostType != null) {
          selectedPostType = widget.initialPostType!;
        } else {
          selectedPostType = controller.selectedPostType;
        }
      });
    });
  }

  List<String> selectedCategories = [];
  double distance = 10.0;
  String selectedRating = 'All';
  String returnType = 'All';
  String selectedPostType = 'all';
  String selectedSort = 'Newest First';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: context.surfaceColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildHeader(),
            ),
            Divider(color: context.dividerColor, thickness: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySection(),
                    const SizedBox(height: 20),
                    _buildDistanceSection(),
                    const SizedBox(height: 20),
                    _buildReturnTypeSection(),
                    const SizedBox(height: 20),
                    _buildSortBySection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: context.isDarkMode
                        ? Colors.black54
                        : context.dividerColor.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48), // Balance for close button
        Expanded(
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.filter,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.textColor,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: context.textColor, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.category, style: _sectionTitleStyle()),
        const SizedBox(height: 12),
        Consumer<TradeController>(
          builder: (context, tradeController, child) {
            if (tradeController.isLoading && tradeController.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (tradeController.categories.isEmpty) {
              return Text(
                'No categories available',
                style: TextStyle(color: context.subTextColor, fontSize: 14),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 45,
                crossAxisSpacing: 16,
                mainAxisSpacing: 8,
              ),
              itemCount: tradeController.categories.length,
              itemBuilder: (context, index) {
                final category = tradeController.categories[index];
                bool isSelected = selectedCategories.contains(category.name);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCategories.remove(category.name);
                      } else {
                        selectedCategories.add(category.name);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? context.primaryColor : context.surfaceColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? context.primaryColor : context.dividerColor,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 16, color: context.onPrimaryColor)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.subTextColor,
                            fontFamily: FontFamily.openSans,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.distance, style: _sectionTitleStyle()),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Slider(
                padding: EdgeInsets.zero,
                value: distance,
                min: 0,
                max: 50,
                activeColor: context.primaryColor,
                inactiveColor: context.isDarkMode ? Colors.white12 : Colors.grey.shade200,
                thumbColor: context.primaryColor,
                onChanged: (val) {
                  setState(() => distance = val);
                  context.read<TradeController>().setDistance(
                        val,
                        triggerFetch: true,
                        fetchType: selectedPostType,
                      );
                },
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 70,
              child: Text(
                '${distance.round()} km',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textColor,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Show items near you',
          style: TextStyle(fontSize: 14, color: context.subTextColor),
        ),
      ],
    );
  }

  Widget _buildReturnTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What do they want in return?', style: _sectionTitleStyle()),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeButton('Price'),
            const SizedBox(width: 16),
            _buildTypeButton('Item'),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type) {
    bool isSelected = returnType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => returnType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.primaryColor : context.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? context.primaryColor : context.dividerColor,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? context.onPrimaryColor : context.subTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortBySection() {
    final sortOptions = [
      {'label': 'Nearest', 'value': 'Nearest First'},
      {'label': 'Farthest', 'value': 'Farthest First'},
      {'label': AppLocalizations.of(context)!.newest, 'value': 'Newest First'},
      {'label': AppLocalizations.of(context)!.oldest, 'value': 'Oldest First'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.sortBy, style: _sectionTitleStyle()),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sortOptions.map((option) {
            bool isSelected = selectedSort == option['value'];
            return GestureDetector(
              onTap: () => setState(() => selectedSort = option['value']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? context.primaryColor : context.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? context.primaryColor : context.dividerColor,
                  ),
                ),
                child: Text(
                  option['label']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? context.onPrimaryColor : context.subTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final controller = context.read<TradeController>();

              controller.setDistance(distance);
              controller.updateFilters(
                categories: selectedCategories,
                rating: selectedRating,
                returnType: returnType,
                postType: selectedPostType,
                sort: selectedSort,
              );

              if (widget.initialPostType == 'give') {
                controller.fetchGivePosts(refresh: true);
              } else if (widget.initialPostType == 'take') {
                controller.fetchTakePosts(refresh: true);
              } else {
                controller.fetchHomePosts(refresh: true);
              }

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              AppLocalizations.of(context)!.apply,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.onPrimaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.read<TradeController>().resetFilters();
              setState(() {
                selectedCategories.clear();
                distance = 10.0;
                selectedRating = 'All';
                returnType = 'All';
                selectedSort = 'Nearest First';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.isDarkMode ? Colors.white10 : const Color(0xFFF0F2F5),
              foregroundColor: context.textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              AppLocalizations.of(context)!.reset,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: context.textColor,
      fontFamily: FontFamily.openSans,
    );
  }
}
