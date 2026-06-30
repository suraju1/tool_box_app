import 'package:flutter/material.dart';
import 'web_sidebar.dart';
import 'web_header.dart';
import 'web_profile_drawer.dart';

class WebDashboardWrapper extends StatelessWidget {
  final Widget child;
  const WebDashboardWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          endDrawer: const WebProfileDrawer(),
          drawer: isNarrow ? const WebSidebar() : null,
          body: Row(
            children: [
              // 1. LEFT SIDEBAR (Only visible on wide screens)
              if (!isNarrow) const WebSidebar(),

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
      },
    );
  }
}
