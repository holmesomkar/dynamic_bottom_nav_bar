import 'package:flutter/material.dart';

import 'overflow_nav_bar_theme.dart';
import 'nav_item.dart';

/// Sectioned two-column menu card that slides up out of the nav bar like a
/// bottom sheet.
class NavMenuSheet extends StatelessWidget {
  const NavMenuSheet({
    super.key,
    required this.animation,
    required this.interactive,
    required this.sections,
    required this.onSelected,
    required this.theme,
  });

  /// 0 = hidden below the bar's bottom edge, 1 = fully open.
  final Animation<double> animation;
  final bool interactive;
  final List<NavSection> sections;
  final ValueChanged<NavItem> onSelected;
  final DynamicNavBarTheme theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Offstage(
        offstage: animation.value == 0,
        child: IgnorePointer(
          ignoring: !interactive,
          child: ExcludeSemantics(
            excluding: !interactive,
            // Clip only at the bar's bottom edge so the sheet appears to rise
            // out of the bar while its shadow stays visible on other sides.
            child: ClipRect(
              clipper: const _BottomEdgeClipper(),
              child: FractionalTranslation(
                translation: Offset(0, 1 - animation.value),
                child: child,
              ),
            ),
          ),
        ),
      ),
      child: Material(
        color: theme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: DynamicNavBarTheme.buttonRadius,
          side: BorderSide(color: theme.borderColor),
        ),
        shadowColor: Colors.black26,
        elevation: 6,
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 16,
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                    color: theme.dividerColor,
                  ),
                _MenuSection(
                  section: sections[i],
                  theme: theme,
                  onSelected: onSelected,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomEdgeClipper extends CustomClipper<Rect> {
  const _BottomEdgeClipper();

  static const double _shadowRoom = 24;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    -_shadowRoom,
    -_shadowRoom,
    size.width + _shadowRoom,
    size.height,
  );

  @override
  bool shouldReclip(_BottomEdgeClipper oldClipper) => false;
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.section,
    required this.theme,
    required this.onSelected,
  });

  final NavSection section;
  final DynamicNavBarTheme theme;
  final ValueChanged<NavItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = section.items;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
          child: Text(section.title, style: theme.resolvedSectionTitleStyle),
        ),
        for (var i = 0; i < items.length; i += 2)
          Row(
            children: [
              Expanded(child: _menuItem(items[i])),
              Expanded(
                child: i + 1 < items.length
                    ? _menuItem(items[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _menuItem(NavItem item) {
    return InkWell(
      onTap: () => onSelected(item),
      borderRadius: DynamicNavBarTheme.pillRadius,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(item.icon, size: theme.iconSize, color: theme.iconColor),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                item.label,
                style: theme.resolvedMenuItemStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
