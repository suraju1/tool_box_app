import 'package:flutter/material.dart';
import 'web_sidebar.dart';
import 'web_header.dart';

class WebDashboardWrapper extends StatelessWidget {
  final Widget child;
  const WebDashboardWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // 1. LEFT SIDEBAR
          const WebSidebar(),
          
          // 2. MAIN CONTENT AREA (Header + Content)
          Expanded(
            child: Column(
              children: [
                // Top Header AppBar
                const WebHeader(),
                
                // Content Area
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
