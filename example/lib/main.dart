import 'package:dynamic_bottom_nav_bar/dynamic_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

abstract final class Items {
  static const home = NavItem(
    id: 'home',
    label: 'Home',
    icon: Icons.home_outlined,
  );
  static const campaigns = NavItem(
    id: 'campaigns',
    label: 'Campaigns',
    icon: Icons.campaign_outlined,
  );
  static const todo = NavItem(
    id: 'todo',
    label: 'To do',
    icon: Icons.assignment_turned_in_outlined,
  );
  static const documents = NavItem(
    id: 'documents',
    label: 'Documents',
    icon: Icons.description_outlined,
  );
  static const postManager = NavItem(
    id: 'post-manager',
    label: 'Post Manager',
    icon: Icons.edit_calendar_outlined,
  );
  static const communication = NavItem(
    id: 'communication',
    label: 'Communication',
    icon: Icons.view_quilt_outlined,
  );
  static const myCalendar = NavItem(
    id: 'my-calendar',
    label: 'My Calendar',
    icon: Icons.calendar_today_outlined,
  );
  static const insights = NavItem(
    id: 'insights',
    label: 'Insights',
    icon: Icons.bar_chart_outlined,
  );
  static const activityHub = NavItem(
    id: 'activity-hub',
    label: 'Activity Hub',
    icon: Icons.monitor_heart_outlined,
  );
  static const sites = NavItem(
    id: 'sites',
    label: 'Sites',
    icon: Icons.person_pin_circle_outlined,
  );
  static const users = NavItem(
    id: 'users',
    label: 'Users',
    icon: Icons.people_outline,
  );
  static const audience = NavItem(
    id: 'audience',
    label: 'Audience',
    icon: Icons.track_changes_outlined,
  );
  static const administration = NavItem(
    id: 'administration',
    label: 'Administration',
    icon: Icons.settings_outlined,
  );
}

const pinned = [Items.home, Items.todo, Items.communication, Items.sites];

const sections = [
  NavSection(
    title: 'Manage',
    items: [Items.campaigns, Items.todo, Items.documents, Items.postManager],
  ),
  NavSection(title: 'Personal', items: [Items.communication, Items.myCalendar]),
  NavSection(title: 'Analyze', items: [Items.insights, Items.activityHub]),
  NavSection(
    title: 'Configure',
    items: [Items.sites, Items.users, Items.audience, Items.administration],
  ),
];

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  NavItem _selected = Items.home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DynamicNavScaffold(
        pinnedItems: pinned,
        sections: sections,
        selectedId: _selected.id,
        onItemSelected: (item) => setState(() => _selected = item),
        body: _PlaceholderPage(item: _selected),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.item});

  final NavItem item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 48,
                  color: const DynamicNavBarTheme().primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
