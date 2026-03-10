import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tool_bocs/routes/app_route_pages.dart';
import 'core/constants/app_theme.dart';
import 'core/controller/theme_controller.dart';
import 'package:tool_bocs/features/network_connectivity/view/connectivity_wrapper.dart';
import 'package:tool_bocs/routes/navigator_key.dart';

import 'routes/app_routes.dart';

class ToolUcsApp extends StatelessWidget {
  const ToolUcsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return ConnectivityWrapper(
      child: MaterialApp(
        title: 'TOOLUCS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        navigatorKey: navigatorKey,
        initialRoute: AppRoutes.splash,
        routes: AppPages.routes,
      ),
    );
  }
}
