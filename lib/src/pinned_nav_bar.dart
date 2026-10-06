import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'dynamic_bottom_nav_bar_theme.dart';
import 'nav_item.dart';
import 'text_measure.dart';

const double _innerPadding = 8;
const double _iconSidePadding = 11;
const double _pillPaddingEnd = 12;
const double _labelGap = 6;

/// White rounded bar of pinned items. The selected item expands into a pill
/// with its label; the other slots share the remaining width.
class PinnedNavBar extends StatefulWidget {
  const PinnedNavBar({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    required this.theme,
  });

  final List<NavItem> items;
  final String selectedId;
  final ValueChanged<NavItem> onSelected;
  final DynamicNavBarTheme theme;

  @override
  State<PinnedNavBar> createState() => _PinnedNavBarState();
}

class _PinnedNavBarState extends State<PinnedNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.theme.selectionDuration,
    value: 1,
  );
  late String _previousId = widget.selectedId;

  @override
  void didUpdateWidget(PinnedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.theme.selectionDuration;
    if (oldWidget.selectedId != widget.selectedId) {
      _previousId = oldWidget.selectedId;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 1 = fully expanded pill, 0 = icon only.
  double _expansion(String id, double t) {
    if (id == widget.selectedId) return t;
    if (id == _previousId) return 1 - t;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final collapsedPill = theme.iconSize + _iconSidePadding * 2;
    return Container(
      height: theme.barHeight,
      padding: const EdgeInsets.symmetric(horizontal: _innerPadding),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: DynamicNavBarTheme.barRadius,
        boxShadow: DynamicNavBarTheme.shadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;
          final count = widget.items.length;
          final maxPill = math.max(
            collapsedPill,
            available - (count - 1) * collapsedPill,
          );
          final pillWidths = {
            for (final item in widget.items)
              item.id: math.min(maxPill, _expandedWidth(context, item)),
          };
          // Width each non-selected slot gets once `id` is fully selected.
          double restingSlot(String id) =>
              pillWidths.containsKey(id) && count > 1
              ? (available - pillWidths[id]!) / (count - 1)
              : available / count;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = DynamicNavBarTheme.curve.transform(_controller.value);
              final slot = lerpDouble(
                restingSlot(_previousId),
                restingSlot(widget.selectedId),
                t,
              )!;
              return Row(
                children: [
                  for (final item in widget.items)
                    _buildSlot(
                      item,
                      slot,
                      collapsedPill,
                      pillWidths[item.id]!,
                      _expansion(item.id, t),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSlot(
    NavItem item,
    double slot,
    double collapsedPill,
    double pillWidth,
    double expansion,
  ) {
    // Flex keeps slots summing to the bar width at every animation frame.
    final width = lerpDouble(slot, pillWidth, expansion)!;
    return Expanded(
      flex: math.max(1, (width * 100).round()),
      child: _PinnedNavTile(
        item: item,
        theme: widget.theme,
        expansion: expansion,
        collapsedWidth: collapsedPill,
        expandedWidth: pillWidth,
        onTap: () => widget.onSelected(item),
      ),
    );
  }

  double _expandedWidth(BuildContext context, NavItem item) =>
      _iconSidePadding +
      widget.theme.iconSize +
      _labelGap +
      measureText(context, item.label, widget.theme.resolvedLabelStyle) +
      _pillPaddingEnd;
}

class _PinnedNavTile extends StatelessWidget {
  const _PinnedNavTile({
    required this.item,
    required this.theme,
    required this.expansion,
    required this.collapsedWidth,
    required this.expandedWidth,
    required this.onTap,
  });

  final NavItem item;
  final DynamicNavBarTheme theme;
  final double expansion;
  final double collapsedWidth;
  final double expandedWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelWidth = math.max(
      0.0,
      expandedWidth -
          _iconSidePadding -
          theme.iconSize -
          _labelGap -
          _pillPaddingEnd,
    );
    return Semantics(
      button: true,
      selected: expansion == 1,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Container(
            width: lerpDouble(collapsedWidth, expandedWidth, expansion),
            height: theme.pillHeight,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(
                alpha: theme.primaryColor.a * expansion,
              ),
              borderRadius: DynamicNavBarTheme.pillRadius,
            ),
            // Icon stays anchored left while the label is revealed by the
            // growing pill.
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: _iconSidePadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: theme.iconSize,
                      color: Color.lerp(
                        theme.iconColor,
                        theme.selectedForegroundColor,
                        expansion,
                      ),
                    ),
                    if (expansion > 0) ...[
                      const SizedBox(width: _labelGap),
                      Opacity(
                        opacity: expansion,
                        child: SizedBox(
                          width: labelWidth,
                          child: Text(
                            item.label,
                            style: theme.resolvedLabelStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
