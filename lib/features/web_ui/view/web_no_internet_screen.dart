import 'package:flutter/material.dart';
import 'package:tool_bocs/l10n/generated/app_localizations.dart';
import 'package:tool_bocs/util/colors.dart';
import 'package:tool_bocs/util/connectivity_service.dart';
import 'package:tool_bocs/util/font_family.dart';

class WebNoInternetScreen extends StatefulWidget {
  final VoidCallback? onConnected;

  const WebNoInternetScreen({super.key, this.onConnected});

  @override
  State<WebNoInternetScreen> createState() => _WebNoInternetScreenState();
}

class _WebNoInternetScreenState extends State<WebNoInternetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _connectivityService.isConnected.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (_connectivityService.isConnected.value) {
      if (widget.onConnected != null) {
        widget.onConnected!();
      }
    }
  }

  @override
  void dispose() {
    _connectivityService.isConnected.removeListener(_onConnectivityChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: context.dividerColor.withOpacity(0.5)),
                boxShadow: context.isDarkMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? Colors.white10
                          : context.surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.primaryColor, width: 2),
                    ),
                    child: Icon(Icons.wifi_off_rounded,
                        size: 70, color: context.primaryColor),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    AppLocalizations.of(context)!.noInternetConnection,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.openSans,
                      fontSize: 32,
                      color: context.textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!
                        .pleaseCheckYourInternetConnectionnand,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.openSans,
                      fontSize: 18,
                      color: context.subTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _connectivityService.checkConnectivity();
                        if (_connectivityService.hasConnection) {
                          if (widget.onConnected != null) {
                            widget.onConnected!();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(AppLocalizations.of(context)!.retryConnection,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              context.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppLocalizations.of(context)!
                            .checkingConnectionAutomatically,
                        style: TextStyle(
                          fontFamily: FontFamily.openSans,
                          fontSize: 14,
                          color: context.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
