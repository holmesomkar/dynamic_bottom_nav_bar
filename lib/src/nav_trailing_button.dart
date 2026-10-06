import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'overflow_nav_bar_theme.dart';
import 'nav_item.dart';
import 'text_measure.dart';

const double _iconBox = 26;
const double _labelGap = 6;
const double _endPadding = 16;

/// Button to the right of the pinned bar.
/// - otherwise                → square with the "more" icon
/// - non-pinned item selected → filled pill showing that item
/// - menu open                → icon rotates into ✕ in step with the menu.
///   If a non-pinned item is selected its label stays visible and spills
///   past the screen edge, keeping ✕ where the square button sits.
class NavTrailingButton extends StatefulWidget {
  const NavTrailingButton({
    super.key,
    required this.menuAnimation,
    required this.isMenuOpen,
    required this.selectedOverflowItem,
    required this.onTap,
    required this.theme,
  });

  /// 0 = menu closed, 1 = menu open. Shared with the menu sheet.
  final Animation<double> menuAnimation;
  final bool isMenuOpen;
  final NavItem? selectedOverflowItem;
  final VoidCallback onTap;
  final DynamicNavBarTheme theme;

  @override
  State<NavTrailingButton> createState() => _NavTrailingButtonState();
}

class _NavTrailingButtonState extends State<NavTrailingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: widget.theme.selectionDuration,
    value: widget.selectedOverflowItem == null ? 0 : 1,
  );
  // Kept after deselection so the pill can animate out with its label.
  late NavItem? _shownItem = widget.selectedOverflowItem;

  @override
  void didUpdateWidget(NavTrailingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _presence.duration = widget.theme.selectionDuration;
    final item = widget.selectedOverflowItem;
    if (item?.id == oldWidget.selectedOverflowItem?.id) return;
    if (item != null) {
      _shownItem = item;
      _presence.forward();
    } else {
      _presence.reverse();
    }
  }

  @override
  void dispose() {
    _presence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final item = _shownItem;
    final labelStyle = theme.resolvedLabelStyle;
    final labelWidth = item == null
        ? 0.0
        : measureText(context, item.label, labelStyle);
    final square = theme.barHeight;
    final iconInset = (square - _iconBox) / 2;
    final pillExtra =
        iconInset + _iconBox + _labelGap + labelWidth + _endPadding - square;

    return Semantics(
      button: true,
      label: widget.isMenuOpen ? 'Close menu' : 'Open menu',
      value: widget.selectedOverflowItem?.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.menuAnimation, _presence]),
          builder: (context, _) {
            final t = widget.menuAnimation.value;
            final p = DynamicNavBarTheme.curve.transform(_presence.value);
            final fill = math.max(t, p);
            final extra = p * pillExtra;

            // The layout slot shrinks back to a square as the menu opens,
            // while the pill keeps its width and overflows to the right.
            return SizedBox(
              width: square + extra * (1 - t),
              height: square,
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: Container(
                  width: square + extra,
                  height: square,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      theme.surfaceColor,
                      theme.primaryColor,
                      fill,
                    ),
                    borderRadius: DynamicNavBarTheme.buttonRadius,
                    border: Border.all(
                      color: Color.lerp(
                        theme.borderColor,
                        theme.primaryColor,
                        fill,
                      )!,
                    ),
                    boxShadow: DynamicNavBarTheme.shadow,
                  ),
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(left: iconInset),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: t * math.pi / 2,
                            child: SizedBox.square(
                              dimension: _iconBox,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: (1 - p) * (1 - t),
                                    child: Icon(
                                      theme.moreIcon,
                                      size: theme.iconSize,
                                      color: theme.iconColor,
                                    ),
                                  ),
                                  if (item != null)
                                    Opacity(
                                      opacity: p * (1 - t),
                                      child: Icon(
                                        item.icon,
                                        size: theme.iconSize,
                                        color: theme.selectedForegroundColor,
                                      ),
                                    ),
                                  Opacity(
                                    opacity: t,
                                    child: Icon(
                                      theme.closeIcon,
                                      size: _iconBox,
                                      color: theme.selectedForegroundColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (item != null && p > 0) ...[
                            const SizedBox(width: _labelGap),
                            Opacity(
                              opacity: p,
                              child: Text(
                                item.label,
                                style: labelStyle,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
