import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';

/// Оболочка с вкладками.
/// Телефон — нижняя панель NavigationBar, планшет или альбомная ориентация —
/// боковая NavigationRail. У каждой вкладки свой стек навигации (StatefulShellRoute).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) => navigationShell.goBranch(
        index,
        // Повторное нажатие на активную вкладку возвращает к её началу.
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final items = [
      (Icons.home_outlined, Icons.home, s.home),
      (Icons.search, Icons.manage_search, s.search),
      (Icons.star_outline, Icons.star, s.favorites),
      (Icons.settings_outlined, Icons.settings, s.settings),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 640) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onSelect,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final (icon, selected, label) in items)
                      NavigationRailDestination(
                        icon: Icon(icon),
                        selectedIcon: Icon(selected),
                        label: Text(label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onSelect,
            destinations: [
              for (final (icon, selected, label) in items)
                NavigationDestination(
                  icon: Icon(icon),
                  selectedIcon: Icon(selected),
                  label: label,
                ),
            ],
          ),
        );
      },
    );
  }
}
