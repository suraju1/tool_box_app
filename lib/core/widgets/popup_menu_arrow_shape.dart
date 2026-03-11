import 'package:flutter/material.dart';

class PopupMenuArrowShape extends ShapeBorder {
  final double borderRadius;
  final double arrowWidth;
  final double arrowHeight;

  const PopupMenuArrowShape({
    this.borderRadius = 12.0,
    this.arrowWidth = 16.0,
    this.arrowHeight = 10.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
        rect.topLeft + Offset(0, arrowHeight), rect.bottomRight);
    final double x = rect.width - 24; // Position arrow near the right side

    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)))
      ..moveTo(x - arrowWidth / 2, rect.top)
      ..lineTo(x, rect.top - arrowHeight)
      ..lineTo(x + arrowWidth / 2, rect.top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
