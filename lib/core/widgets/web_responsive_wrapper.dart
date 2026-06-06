import 'package:flutter/material.dart';

class WebResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const WebResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // We are now using ResponsiveLayout for specific screens,
    // so we no longer restrict the entire app's width.
    return child;
  }
}
