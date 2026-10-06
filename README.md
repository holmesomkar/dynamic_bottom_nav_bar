# dynamic_nav_bar

A pill-style bottom navigation bar for Flutter with:

- **Pinned items** in a rounded bar. The selected one expands into a pill with its label.
- **Overflow menu** with titled sections in two columns. It slides up out of the bar like a bottom sheet.
- **Dynamic trailing button** that shows a "more" icon, or the selected non-pinned item as a pill. While the menu animates, its icon rotates into ✕.
- **Theming** through `DynamicNavBarTheme`. Every value has a default.

## Install

```yaml
dependencies:
  dynamic_nav_bar:
    git:
      url: https://github.com/holmesomkar/dynamic_nav_bar.git
      ref: v0.1.0
```

## Usage

```dart
import 'package:dynamic_nav_bar/dynamic_nav_bar.dart';

const home = NavItem(id: 'home', label: 'Home', icon: Icons.home_outlined);
const sites = NavItem(id: 'sites', label: 'Sites', icon: Icons.place_outlined);
const users = NavItem(id: 'users', label: 'Users', icon: Icons.people_outline);

DynamicNavScaffold(
  pinnedItems: const [home, sites],
  sections: const [
    NavSection(title: 'Configure', items: [sites, users]),
  ],
  selectedId: selected.id,
  onItemSelected: (item) => setState(() => selected = item),
  body: pageFor(selected),
);
```

Your app controls which item is selected. Pass the current `selectedId` and update it in `onItemSelected`. An item can appear both in `pinnedItems` and in a menu section.

### With go_router

Wrap your destinations in a `ShellRoute` and derive the selection from the location:

```dart
ShellRoute(
  builder: (context, state, child) => DynamicNavScaffold(
    pinnedItems: pinned,
    sections: sections,
    selectedId: idForPath(state.uri.path),
    onItemSelected: (item) => context.go('/${item.id}'),
    body: child,
  ),
  routes: [
    for (final item in allItems)
      GoRoute(
        path: '/${item.id}',
        pageBuilder: (_, __) => NoTransitionPage(child: PageFor(item)),
      ),
  ],
)
```

### Theming

```dart
DynamicNavScaffold(
  theme: const DynamicNavBarTheme(
    primaryColor: Colors.teal,
    backgroundColor: Color(0xFFF4F6F6),
    moreIcon: Icons.apps,
  ),
  ...
)
```

See `DynamicNavBarTheme` for every option: colors, text styles, icons, sizes and animation durations.

## Example

```sh
cd example
flutter run
```
