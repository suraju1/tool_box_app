import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialPostType;
  const FilterBottomSheet({super.key, this.initialPostType});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: _buildHeader(),
            ),
            Divider(color: context.dividerColor, thickness: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySection(),
                    SizedBox(height: 12.h),
                    _buildDistanceSection(),
                    SizedBox(height: 12.h),
                    _buildReturnTypeSection(),
                    SizedBox(height: 12.h),
                    _buildSortBySection(),
                    SizedBox(height: 25.h),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
              decoration: BoxDecoration(
                color: context.surfaceColor,
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
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: context.textColor),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.filter,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: context.textColor,
                fontFamily: FontFamily.openSans,
              ),
            ),
          ),
        ),
        SizedBox(width: 40.w), // To balance the close icon
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.category, style: _sectionTitleStyle()),
        SizedBox(height: 10.h),
        Consumer<TradeController>(
          builder: (context, tradeController, child) {
            if (tradeController.isLoading &&
                tradeController.categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (tradeController.categories.isEmpty) {
              return Text(
                'No categories available',
                style: TextStyle(color: context.subTextColor),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 40.h,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 0.5.h,
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
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.primaryColor
                              : context.surfaceColor,
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: isSelected
                                ? context.primaryColor
                                : context.dividerColor,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14.sp,
                                color: context.onPrimaryColor,
                              )
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 13.sp,
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
        SizedBox(height: 5.h),
        Row(
          children: [
            SizedBox(width: 10.w),
            Expanded(
              child: Slider(
                padding: EdgeInsets.zero,
                value: distance,
                min: 0,
                max: 50,
                activeColor: context.primaryColor,
                inactiveColor:
                    context.isDarkMode ? Colors.white12 : Colors.grey.shade200,
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
            SizedBox(width: 15.w),
            Text(
              '${distance.round()} km',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
          ],
        ),
        Text(
          'Show items near you',
          style: TextStyle(fontSize: 12.sp, color: context.subTextColor),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final ratings = ['4 & above', '3 & above', '2 & above', '1 & above', 'All'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Person Rating', style: _sectionTitleStyle()),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: ratings.map((rating) {
            bool isSelected = selectedRating == rating;
            bool isAll = rating == 'All';
            return GestureDetector(
              onTap: () => setState(() => selectedRating = rating),
              child: Container(
                padding: isAll
                    ? EdgeInsets.symmetric(horizontal: 25.w, vertical: 8.h)
                    : EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color:
                      isSelected ? context.primaryColor : context.surfaceColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                      color: isSelected
                          ? context.primaryColor
                          : context.dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAll) ...[
                      Icon(Icons.star,
                          color: isSelected
                              ? Colors.yellow
                              : Colors.yellow.shade700,
                          size: 16.sp),
                      SizedBox(width: 5.w),
                    ],
                    Text(
                      rating,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected
                            ? context.onPrimaryColor
                            : context.subTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReturnTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What do they want in return?', style: _sectionTitleStyle()),
        SizedBox(height: 10.h),
        Row(
          children: [
            _buildTypeButton('Price'),
            SizedBox(width: 15.w),
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
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? context.primaryColor : context.surfaceColor,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isSelected ? context.primaryColor : context.dividerColor,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: TextStyle(
              fontSize: 16.sp,
              color: isSelected ? context.onPrimaryColor : context.subTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final controller = context.read<TradeController>();

              // 1. Update distance in controller
              controller.setDistance(distance);

              // 2. Update other filters
              controller.updateFilters(
                categories: selectedCategories,
                rating: selectedRating,
                returnType: returnType,
                postType: selectedPostType,
                sort: selectedSort,
              );

              // 3. Trigger fetch based on current screen context
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
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              AppLocalizations.of(context)!.apply,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: context.onPrimaryColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
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
              backgroundColor:
                  context.isDarkMode ? Colors.white10 : const Color(0xFFF0F2F5),
              foregroundColor: context.textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              AppLocalizations.of(context)!.reset,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostTypeSection() {
    final types = [
      {'label': AppLocalizations.of(context)!.all, 'value': 'all'},
      {'label': AppLocalizations.of(context)!.give, 'value': 'give'},
      {'label': AppLocalizations.of(context)!.take, 'value': 'take'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.postType, style: _sectionTitleStyle()),
        SizedBox(height: 10.h),
        Row(
          children: types.map((type) {
            bool isSelected =
                selectedPostType.toLowerCase() == type['value']!.toLowerCase();
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => selectedPostType = type['value']!.toLowerCase()),
                child: Container(
                  margin: EdgeInsets.only(right: type['label'] == AppLocalizations.of(context)!.take ? 0 : 10.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primaryColor
                        : context.surfaceColor,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected
                          ? context.primaryColor
                          : context.dividerColor,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    type['label']!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected
                          ? context.onPrimaryColor
                          : context.subTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortBySection() {
    final sortOptions = [
      {'label': AppLocalizations.of(context)!.distance, 'value': 'Nearest First'},
      {'label': AppLocalizations.of(context)!.newest, 'value': 'Newest First'},
      {'label': AppLocalizations.of(context)!.oldest, 'value': 'Oldest First'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.sortBy, style: _sectionTitleStyle()),
        SizedBox(height: 10.h),
        Row(
          children: sortOptions.map((option) {
            bool isSelected = selectedSort == option['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedSort = option['value']!),
                child: Container(
                  margin: EdgeInsets.only(
                      right: option['label'] == 'Oldest' ? 0 : 10.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primaryColor
                        : context.surfaceColor,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected
                          ? context.primaryColor
                          : context.dividerColor,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option['label']!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected
                          ? context.onPrimaryColor
                          : context.subTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: context.textColor,
      fontFamily: FontFamily.openSans,
    );
  }
}
