import 'package:flutter/material.dart';

class StickySidebarWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final GlobalKey rowKey;

  const StickySidebarWrapper({
    super.key,
    required this.child,
    required this.scrollController,
    required this.rowKey,
  });

  @override
  State<StickySidebarWrapper> createState() => _StickySidebarWrapperState();
}

class _StickySidebarWrapperState extends State<StickySidebarWrapper> {
  final GlobalKey _key = GlobalKey();
  double _offset = 0;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    final currentScroll = widget.scrollController.offset;
    final scrollDelta = currentScroll - _lastScrollOffset;
    _lastScrollOffset = currentScroll;

    final sidebarBox = _key.currentContext?.findRenderObject() as RenderBox?;
    final rowBox =
        widget.rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (sidebarBox == null || rowBox == null) return;

    final sidebarHeight = sidebarBox.size.height;
    final rowHeight = rowBox.size.height;
    final viewportHeight = MediaQuery.of(context).size.height;

    // The maximum offset we can apply without pushing the sidebar outside the bottom of the row
    final double maxOffsetBoundary =
        (rowHeight - sidebarHeight).clamp(0.0, double.infinity);

    const double topMargin = 120.0; // Estimate for header + breadcrumbs

    // The current absolute top position of the row in the scroll view
    // Since we don't have a direct way to get absolute position relative to scroll top,
    // we use a reasonable approximation based on currentScroll.
    // A better way is to find the row's position on screen:
    final rowPositionOnScreen = rowBox.localToGlobal(Offset.zero).dy;

    // We want to calculate an offset that keeps the sidebar visible.
    double newOffset = _offset;

    if (sidebarHeight <= viewportHeight - topMargin) {
      // Sidebar is short enough to stick to the top
      // If rowPositionOnScreen < topMargin, we need to push the sidebar down to keep it at topMargin
      if (rowPositionOnScreen < topMargin) {
        newOffset = _offset + (topMargin - rowPositionOnScreen);
      } else {
        newOffset = 0;
      }
    } else {
      // Sidebar is taller than the viewport
      // If scrolling down, let it scroll naturally until the bottom of the sidebar hits the bottom of the viewport
      final sidebarBottomOnScreen =
          rowPositionOnScreen + _offset + sidebarHeight;

      if (scrollDelta > 0) {
        // Scrolling down (page moves up)
        if (sidebarBottomOnScreen < viewportHeight - 32) {
          // Bottom reached, push it down to stick to the bottom
          newOffset = _offset + (viewportHeight - 32 - sidebarBottomOnScreen);
        }
      } else {
        // Scrolling up (page moves down)
        if (rowPositionOnScreen + _offset > topMargin) {
          // Top reached, pull it up to stick to the top
          newOffset = _offset - ((rowPositionOnScreen + _offset) - topMargin);
        }
      }
    }

    // Clamp the offset to ensure it doesn't go above the top of the row or below the bottom of the row
    newOffset = newOffset.clamp(0.0, maxOffsetBoundary);

    if ((_offset - newOffset).abs() > 0.5) {
      setState(() {
        _offset = newOffset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _offset),
      child: Container(
        key: _key,
        child: widget.child,
      ),
    );
  }
}
