import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // final List<String> categories = [
  //   'Mobiles',
  //   'Electronics',
  //   'Furniture',
  //   'Home',
  //   'Fashion',
  //   'Books',
  //   'Sports',
  //   'Others'
  // ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradeController>().fetchCategories();
    });
  }

  final List<String> selectedCategories = ['Electronics'];
  double distance = 5.0;
  String selectedRating = '4 & above';
  String returnType = 'Price';
  String selectedSort = 'Nearest First';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.77,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: 90.h,
              left: 20.w,
              right: 20.w,
              top: 12.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Divider(color: context.dividerColor, thickness: 1),
                _buildCategorySection(),
                SizedBox(height: 12.h),
                // _buildPostTypeSection(),
                // SizedBox(height: 12.h),
                _buildDistanceSection(),
                SizedBox(height: 12.h),
                _buildRatingSection(),
                SizedBox(height: 12.h),
                _buildReturnTypeSection(),
                SizedBox(height: 12.h),
                _buildSortBySection(),
                SizedBox(height: 25.h),
                // _buildActionButtons(),
                // SizedBox(height: 20.h),
              ],
            ),
          ),
          Positioned(
            bottom: 1.h,
            left: 0,
            right: 0,
            child: Container(
              height: 80.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: context.dividerColor.withOpacity(1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: _buildActionButtons(),
            ),
          ),
        ],
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
              'Filter',
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
        Text('Category', style: _sectionTitleStyle()),
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
                              ? defoultColor
                              : context.surfaceColor,
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: isSelected
                                ? defoultColor
                                : greyColor.withOpacity(0.4),
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14.sp,
                                color: Colors.white,
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
        Text('Distance', style: _sectionTitleStyle()),
        SizedBox(height: 5.h),
        Row(
          children: [
            SizedBox(width: 10.w),
            Expanded(
              child: Slider(
                value: distance,
                min: 0,
                max: 50,
                padding: EdgeInsets.zero,
                activeColor: defoultColor,
                inactiveColor: greyColor.withOpacity(0.4),
                onChanged: (val) => setState(() => distance = val),
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
                  color: isSelected ? defoultColor : context.surfaceColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? defoultColor
                        : greyColor.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAll) ...[
                      Icon(
                        Icons.star,
                        color: isSelected
                            ? Colors.yellow
                            : Colors.yellow.shade700,
                        size: 16.sp,
                      ),
                      SizedBox(width: 5.w),
                    ],
                    Text(
                      rating,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected ? Colors.white : context.subTextColor,
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
            color: isSelected ? defoultColor : context.surfaceColor,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isSelected ? defoultColor : greyColor.withOpacity(0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: TextStyle(
              fontSize: 16.sp,
              color: isSelected ? Colors.white : context.subTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortBySection() {
    final sortOptions = ['Newest First', 'Nearest First', 'Highest Rated'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sort By', style: _sectionTitleStyle()),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: sortOptions.map((option) {
            bool isSelected = selectedSort == option;
            return GestureDetector(
              onTap: () => setState(() => selectedSort = option),
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: isSelected ? defoultColor : context.surfaceColor,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: isSelected ? defoultColor : greyColor,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    option,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.subTextColor,
                      fontFamily: FontFamily.openSans,
                    ),
                  ),
                ],
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
              context.read<TradeController>().fetchHomePosts(
                type: selectedPostType,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: defoultColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                selectedCategories.clear();
                selectedCategories.add('Electronics');
                distance = 5.0;
                selectedRating = '4 & above';
                returnType = 'Price';
                selectedSort = 'Nearest First';
                selectedPostType = 'all';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.isDarkMode
                  ? Colors.white10
                  : const Color(0xFFF3F4F6),
              foregroundColor: context.subTextColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              'Reset',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  String selectedPostType = 'all'; // Default

  Widget _buildPostTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Post Type', style: _sectionTitleStyle()),
        SizedBox(height: 10.h),
        Row(
          children: [
            _buildPostTypeOption('All', 'all'),
            SizedBox(width: 15.w),
            _buildPostTypeOption('Give', 'give'),
            SizedBox(width: 15.w),
            _buildPostTypeOption('Take', 'take'),
          ],
        ),
      ],
    );
  }

  Widget _buildPostTypeOption(String label, String value) {
    bool isSelected = selectedPostType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPostType = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? defoultColor : context.surfaceColor,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isSelected ? defoultColor : greyColor.withOpacity(0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: isSelected ? Colors.white : context.subTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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
