import 'package:flutter/material.dart';

/// Visual configuration for [DynamicNavScaffold]. Every value has a default,
/// so override only what you need:
///
/// ```dart
/// const DynamicNavBarTheme(primaryColor: Colors.teal)
/// ```
@immutable
class DynamicNavBarTheme {
  const DynamicNavBarTheme({
    this.primaryColor = const Color(0xFF0B4EA2),
    this.backgroundColor = const Color(0xFFEEF0F8),
    this.surfaceColor = Colors.white,
    this.iconColor = const Color(0xFF2B2B2B),
    this.selectedForegroundColor = Colors.white,
    this.textColor = const Color(0xFF1F1F1F),
    this.borderColor = const Color(0xFFE2E4EC),
    this.dividerColor = const Color(0xFFE6E6E6),
    this.labelStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
    this.menuSectionTitleStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    this.menuItemStyle = const TextStyle(fontSize: 14),
    this.moreIcon = Icons.dashboard_customize_outlined,
    this.closeIcon = Icons.close,
    this.barHeight = 54,
    this.iconSize = 22,
    this.sidePadding = 8,
    this.gap = 10,
    this.selectionDuration = const Duration(milliseconds: 260),
    this.menuDuration = const Duration(milliseconds: 320),
  });

  /// Fill of the selected pill, the trailing button and the ✕ button.
  final Color primaryColor;

  /// Scaffold background behind the page and the bar.
  final Color backgroundColor;

  /// Fill of the pinned bar, the idle trailing button and the menu.
  final Color surfaceColor;

  /// Unselected icons in the bar and icons in the menu.
  final Color iconColor;

  /// Icon and label color on top of [primaryColor].
  final Color selectedForegroundColor;

  /// Menu section titles and item labels.
  final Color textColor;
  final Color borderColor;
  final Color dividerColor;

  /// Label inside the selected pill and the trailing button.
  final TextStyle labelStyle;
  final TextStyle menuSectionTitleStyle;
  final TextStyle menuItemStyle;

  /// Icon of the trailing button when no overflow item is selected.
  final IconData moreIcon;
  final IconData closeIcon;

  final double barHeight;
  final double iconSize;

  /// Horizontal inset of the bar from the screen edges.
  final double sidePadding;

  /// Space between the pinned bar and the trailing button.
  final double gap;

  final Duration selectionDuration;
  final Duration menuDuration;

  DynamicNavBarTheme copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? iconColor,
    Color? selectedForegroundColor,
    Color? textColor,
    Color? borderColor,
    Color? dividerColor,
    TextStyle? labelStyle,
    TextStyle? menuSectionTitleStyle,
    TextStyle? menuItemStyle,
    IconData? moreIcon,
    IconData? closeIcon,
    double? barHeight,
    double? iconSize,
    double? sidePadding,
    double? gap,
    Duration? selectionDuration,
    Duration? menuDuration,
  }) {
    return DynamicNavBarTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      iconColor: iconColor ?? this.iconColor,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      labelStyle: labelStyle ?? this.labelStyle,
      menuSectionTitleStyle:
          menuSectionTitleStyle ?? this.menuSectionTitleStyle,
      menuItemStyle: menuItemStyle ?? this.menuItemStyle,
      moreIcon: moreIcon ?? this.moreIcon,
      closeIcon: closeIcon ?? this.closeIcon,
      barHeight: barHeight ?? this.barHeight,
      iconSize: iconSize ?? this.iconSize,
      sidePadding: sidePadding ?? this.sidePadding,
      gap: gap ?? this.gap,
      selectionDuration: selectionDuration ?? this.selectionDuration,
      menuDuration: menuDuration ?? this.menuDuration,
    );
  }

  // ── Derived values used by the widgets ──

  TextStyle get resolvedLabelStyle =>
      labelStyle.copyWith(color: selectedForegroundColor);

  TextStyle get resolvedSectionTitleStyle => menuSectionTitleStyle.copyWith(
    color: menuSectionTitleStyle.color ?? textColor,
  );

  TextStyle get resolvedMenuItemStyle =>
      menuItemStyle.copyWith(color: menuItemStyle.color ?? textColor);

  double get pillHeight => barHeight - 16;

  static const BorderRadius barRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(10),
  );
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(8));

  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 2)),
  ];

  static const Curve curve = Curves.easeOutCubic;
}
