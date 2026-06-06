import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/routes/app_routes.dart';
import 'package:tool_bocs/features/trades/controller/trade_controller.dart';
import 'package:tool_bocs/features/bottom_navigation_bar/controller/bottom_navbar_controller.dart';
import 'package:tool_bocs/core/controller/theme_controller.dart';

class WebHeader extends StatelessWidget {
  const WebHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<BottomNavBarController>();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(right: 40),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: greyColor.withOpacity(0.2)),
              ),
              child: _WebSearchBar(
                tabIndex: controller.currentIndex,
                key: ValueKey(controller.currentIndex),
              ),
            ),
          ),
          
          // Theme Toggle
          Consumer<ThemeController>(
            builder: (context, themeController, child) {
              final isDark = themeController.themeMode == ThemeMode.dark || 
                  (themeController.themeMode == ThemeMode.system && 
                   MediaQuery.platformBrightnessOf(context) == Brightness.dark);
              
              return IconButton(
                onPressed: () {
                  themeController.setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: child.key == const ValueKey('dark')
                          ? Tween<double>(begin: 0.5, end: 1.0).animate(animation)
                          : Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark ? 'light' : 'dark'),
                    color: isDark ? Colors.amber : Colors.grey.shade700,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          
          // Action Icons
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
          ),
          const SizedBox(width: 16),
          // User Profile Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: context.primaryColor.withOpacity(0.2),
            child: Icon(Icons.person, color: context.primaryColor, size: 20),
          ),
          const SizedBox(width: 8),
          const Text("User", style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WebSearchBar extends StatefulWidget {
  final int tabIndex;
  
  const _WebSearchBar({required this.tabIndex, super.key});

  @override
  State<_WebSearchBar> createState() => _WebSearchBarState();
}

class _WebSearchBarState extends State<_WebSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  
  Timer? _timer;
  int _currentItemIndex = 0;
  int _currentCharIndex = 0;
  bool _isDeleting = false;
  String _currentHint = "Search...";

  final List<String> _hintItems = [
    "iPhone", "Android Phones", "Tablets", "Smart Watches", "Laptops",
    "Gaming Consoles", "Cameras", "Earbuds & Headphones", "Speakers",
    "Power Banks", "Vehicles", "Cars", "Bikes", "Scooters", "Trucks",
    "Bicycles", "Auto Rickshaw", "Tractors", "Property", "Flats", "Houses",
    "Shops", "Offices", "Land/Plots", "PG & Hostel Rooms", "Fashion", "Shoes",
    "Watches", "Clothes", "Jackets", "Bags", "Sunglasses", "Home & Furniture",
    "Sofa", "Bed", "Dining Table", "Chair", "Cupboard", "Mattress", "TV Unit",
    "Appliances", "Refrigerator", "Washing Machine", "AC", "Cooler",
    "Microwave", "TV"
  ];

  @override
  void initState() {
    super.initState();
    _hintItems.shuffle();
    _controller = TextEditingController();
    _focusNode.addListener(_onFocusChange);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tradeController = context.read<TradeController>();
      String query = '';
      if (widget.tabIndex == 1) {
        query = tradeController.giveSearchQuery;
      } else if (widget.tabIndex == 2) {
        query = tradeController.takeSearchQuery;
      } else {
        query = tradeController.homeSearchQuery;
      }
      
      _controller.text = query;
      
      if (!_focusNode.hasFocus && query.isEmpty) {
        _startAnimation();
      } else {
        setState(() {
          _currentHint = "Search...";
        });
      }
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _timer?.cancel();
      setState(() {
        _currentHint = "Search...";
      });
    } else {
      if (_controller.text.isEmpty) {
        _startAnimation();
      }
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || _focusNode.hasFocus) {
        timer.cancel();
        return;
      }

      final targetWord = "Search \"${_hintItems[_currentItemIndex]}\"";

      setState(() {
        if (_isDeleting) {
          if (_currentCharIndex > 0) {
            _currentCharIndex--;
            _currentHint = targetWord.substring(0, _currentCharIndex);
          } else {
            _isDeleting = false;
            _currentItemIndex = (_currentItemIndex + 1) % _hintItems.length;
          }
        } else {
          if (_currentCharIndex < targetWord.length) {
            _currentCharIndex++;
            _currentHint = targetWord.substring(0, _currentCharIndex);
          } else {
            _isDeleting = true;
            _timer?.cancel();
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && !_focusNode.hasFocus && _controller.text.isEmpty) {
                _startAnimation();
              }
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlignVertical: TextAlignVertical.center,
      onChanged: (val) {
        String type = 'all';
        if (widget.tabIndex == 1) {
          type = 'give';
        } else if (widget.tabIndex == 2) {
          type = 'take';
        }
        
        context.read<TradeController>().setSearchQuery(val, type: type);
      },
      decoration: InputDecoration(
        isDense: true,
        hintText: _currentHint,
        hintStyle: TextStyle(fontSize: 14, color: greyColor),
        prefixIcon: Icon(Icons.search, color: greyColor, size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
