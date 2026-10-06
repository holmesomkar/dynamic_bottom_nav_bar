import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dynamic_nav_bar_theme.dart';
import 'nav_item.dart';
import 'nav_menu_sheet.dart';
import 'nav_trailing_button.dart';
import 'pinned_nav_bar.dart';

/// Scaffold that hosts [body] above the dynamic nav bar and owns the menu
/// overlay.
///
/// Selection is controlled from outside: pass the current [selectedId] and
/// update it in [onItemSelected] (e.g. by navigating with your router).
class DynamicNavScaffold extends StatefulWidget {
  const DynamicNavScaffold({
    super.key,
    required this.body,
    required this.pinnedItems,
    required this.sections,
    required this.selectedId,
    required this.onItemSelected,
    this.theme = const DynamicNavBarTheme(),
  }) : assert(pinnedItems.length > 0, 'pinnedItems must not be empty');

  final Widget body;

  /// Items always visible in the bar.
  final List<NavItem> pinnedItems;

  /// Groups shown in the overflow menu. Items may also appear in
  /// [pinnedItems].
  final List<NavSection> sections;

  /// Id of the currently selected item, pinned or not.
  final String selectedId;
  final ValueChanged<NavItem> onItemSelected;
  final DynamicNavBarTheme theme;

  @override
  State<DynamicNavScaffold> createState() => _DynamicNavScaffoldState();
}

class _DynamicNavScaffoldState extends State<DynamicNavScaffold>
    with SingleTickerProviderStateMixin {
  bool _menuOpen = false;

  // Drives both the sheet slide and the trailing icon rotation.
  late final AnimationController _menuController = AnimationController(
    vsync: this,
    duration: widget.theme.menuDuration,
  );
  late final Animation<double> _menuAnimation = CurvedAnimation(
    parent: _menuController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void didUpdateWidget(DynamicNavScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _menuController.duration = widget.theme.menuDuration;
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _setMenuOpen(bool open) {
    setState(() => _menuOpen = open);
    open ? _menuController.forward() : _menuController.reverse();
  }

  void _select(NavItem item) {
    _setMenuOpen(false);
    if (item.id != widget.selectedId) widget.onItemSelected(item);
  }

  NavItem? get _selectedOverflowItem {
    if (widget.pinnedItems.any((item) => item.id == widget.selectedId)) {
      return null;
    }
    for (final section in widget.sections) {
      for (final item in section.items) {
        if (item.id == widget.selectedId) return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    // Keeps the bar clear of rounded screen corners and the home indicator.
    final bottom = math.max(16.0, MediaQuery.viewPaddingOf(context).bottom);
    final top = MediaQuery.paddingOf(context).top;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final side = theme.sidePadding;

    return PopScope(
      canPop: !_menuOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _setMenuOpen(false);
      },
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        body: Stack(
          children: [
            Positioned.fill(
              bottom: bottom + theme.barHeight + theme.gap,
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: widget.body,
              ),
            ),
            if (_menuOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _setMenuOpen(false),
                ),
              ),
            Positioned(
              left: side,
              right: side,
              bottom: bottom,
              child: Row(
                children: [
                  Expanded(
                    child: PinnedNavBar(
                      items: widget.pinnedItems,
                      selectedId: widget.selectedId,
                      onSelected: _select,
                      theme: theme,
                    ),
                  ),
                  SizedBox(width: theme.gap),
                  NavTrailingButton(
                    menuAnimation: _menuAnimation,
                    isMenuOpen: _menuOpen,
                    selectedOverflowItem: _selectedOverflowItem,
                    onTap: () => _setMenuOpen(!_menuOpen),
                    theme: theme,
                  ),
                ],
              ),
            ),
            // Covers the pinned bar; leaves the ✕ button exposed on the right.
            Positioned(
              left: side,
              right: side + theme.barHeight + theme.gap,
              bottom: bottom,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: math.max(0, screenHeight - top - bottom - 24),
                ),
                child: NavMenuSheet(
                  animation: _menuAnimation,
                  interactive: _menuOpen,
                  sections: widget.sections,
                  onSelected: _select,
                  theme: theme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
