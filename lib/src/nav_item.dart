import 'package:flutter/widgets.dart';

/// A navigation destination. [id] must be unique across all items.
@immutable
class NavItem {
  const NavItem({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;

  @override
  bool operator ==(Object other) => other is NavItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A titled group of items shown in the overflow menu.
@immutable
class NavSection {
  const NavSection({required this.title, required this.items});

  final String title;
  final List<NavItem> items;
}
