import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/font_family.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';

class WebSortDialog extends StatefulWidget {
  final String? initialPostType;
  const WebSortDialog({super.key, this.initialPostType});

  static Future<void> show(BuildContext context, {String? initialPostType}) {
    return showDialog(
      context: context,
      builder: (context) => WebSortDialog(initialPostType: initialPostType),
    );
  }

  @override
  State<WebSortDialog> createState() => _WebSortDialogState();
}

class _WebSortDialogState extends State<WebSortDialog> {
  // Two independent sort selections
  String selectedDistanceSort = 'Nearest First';
  String selectedDateSort = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TradeController>();
      setState(() {
        selectedDistanceSort = controller.selectedDistanceSort;
        selectedDateSort = controller.selectedDateSort;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: context.surfaceColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildHeader(),
            ),
            Divider(color: context.dividerColor, thickness: 1),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // DISTANCE group
                  _buildGroupLabel('DISTANCE'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildDistancePill('Nearest', 'Nearest First'),
                      _buildDistancePill('Farthest', 'Farthest First'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // DATE ADDED group
                  _buildGroupLabel('DATE ADDED'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildDatePill(
                          AppLocalizations.of(context)!.newest, 'Newest First'),
                      _buildDatePill(
                          AppLocalizations.of(context)!.oldest, 'Oldest First'),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Action Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
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
        const SizedBox(width: 48),
        Expanded(
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.sortBy,
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

  // Widget _buildGroupLabel(String label) {
  //   return Text(
  //     label,
  //     style: TextStyle(
  //       fontSize: 12,
  //       fontWeight: FontWeight.w700,
  //       color: context.subTextColor,
  //       fontFamily: FontFamily.openSans,
  //       letterSpacing: 1.5,
  //     ),
  //   );
  // }
  Widget _buildGroupLabel(String label) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.subTextColor,
          fontFamily: FontFamily.openSans,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  /// Distance group pill — radio-like within group
  Widget _buildDistancePill(String label, String value) {
    final isSelected = selectedDistanceSort == value;
    return GestureDetector(
      onTap: () => setState(() {
        selectedDistanceSort = isSelected ? '' : value;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : context.isDarkMode
                    ? Colors.white24
                    : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? context.onPrimaryColor : context.textColor,
            fontFamily: FontFamily.openSans,
          ),
        ),
      ),
    );
  }

  /// Date group pill — independent from distance group
  Widget _buildDatePill(String label, String value) {
    final isSelected = selectedDateSort == value;
    return GestureDetector(
      onTap: () => setState(() {
        selectedDateSort = isSelected ? '' : value;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : context.isDarkMode
                    ? Colors.white24
                    : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? context.onPrimaryColor : context.textColor,
            fontFamily: FontFamily.openSans,
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
              controller.updateFilters(
                distanceSort: selectedDistanceSort,
                dateSort: selectedDateSort,
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
              setState(() {
                selectedDistanceSort = 'Nearest First';
                selectedDateSort = '';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  context.isDarkMode ? Colors.white10 : const Color(0xFFF0F2F5),
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
}
