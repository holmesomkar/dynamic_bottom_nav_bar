import 'package:dynamic_bottom_nav_bar/dynamic_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _home = NavItem(id: 'home', label: 'Home', icon: Icons.home_outlined);
const _sites = NavItem(id: 'sites', label: 'Sites', icon: Icons.place_outlined);
const _users = NavItem(id: 'users', label: 'Users', icon: Icons.people_outline);

class _Host extends StatefulWidget {
  const _Host({this.theme = const DynamicNavBarTheme()});

  final DynamicNavBarTheme theme;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  NavItem _selected = _home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DynamicNavScaffold(
        pinnedItems: const [_home, _sites],
        sections: const [
          NavSection(title: 'Configure', items: [_sites, _users]),
        ],
        selectedId: _selected.id,
        onItemSelected: (item) => setState(() => _selected = item),
        theme: widget.theme,
        body: Center(child: Text('page:${_selected.id}')),
      ),
    );
  }
}

Finder _menuItem(String label) =>
    find.descendant(of: find.byType(InkWell), matching: find.text(label));

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Open menu'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping a pinned item selects it', (tester) async {
    await tester.pumpWidget(const _Host());
    expect(find.text('page:home'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Sites'));
    await tester.pumpAndSettle();

    expect(find.text('page:sites'), findsOneWidget);
  });

  testWidgets('selecting a non-pinned item shows it in the trailing button', (
    tester,
  ) async {
    await tester.pumpWidget(const _Host());

    await _openMenu(tester);
    expect(find.bySemanticsLabel('Close menu'), findsOneWidget);

    await tester.tap(_menuItem('Users'));
    await tester.pumpAndSettle();

    expect(find.text('page:users'), findsOneWidget);
    expect(find.bySemanticsLabel('Open menu'), findsOneWidget);
    expect(find.text('Users'), findsWidgets);
  });

  testWidgets('tapping outside closes the menu', (tester) async {
    await tester.pumpWidget(const _Host());

    await _openMenu(tester);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Open menu'), findsOneWidget);
    expect(find.text('page:home'), findsOneWidget);
  });

  testWidgets('reopening the menu keeps the non-pinned label next to ✕', (
    tester,
  ) async {
    await tester.pumpWidget(const _Host());
    await _openMenu(tester);
    await tester.tap(_menuItem('Users'));
    await tester.pumpAndSettle();

    await _openMenu(tester);

    expect(find.bySemanticsLabel('Close menu'), findsOneWidget);
    // One label in the menu, one in the trailing pill.
    expect(find.text('Users'), findsNWidgets(2));
  });

  testWidgets('applies a custom theme', (tester) async {
    const background = Color(0xFF123456);
    await tester.pumpWidget(
      const _Host(theme: DynamicNavBarTheme(backgroundColor: background)),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, background);
  });
}
