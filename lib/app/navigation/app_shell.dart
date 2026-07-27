import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:primeatlas/app/design_system/app_icon.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: AppIcon(icon: AppIconKey.route, semanticLabel: '旅程'),
            selectedIcon: AppIcon(
              icon: AppIconKey.route,
              semanticLabel: '旅程，已选择',
            ),
            label: '旅程',
          ),
          NavigationDestination(
            icon: AppIcon(icon: AppIconKey.userRound, semanticLabel: '我的'),
            selectedIcon: AppIcon(
              icon: AppIconKey.userRound,
              semanticLabel: '我的，已选择',
            ),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
