// ============================================================================
// lib/presentation/widgets/navigation/bottom_nav_bar.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../router/route_paths.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    final navItems = [
      BottomNavItem(
        icon: LucideIcons.house,
        activeIcon: LucideIcons.house600,
        label: 'Dashboard',
        route: RoutePaths.dashboard,
      ),
      BottomNavItem(
        icon: LucideIcons.wallet,
        activeIcon: LucideIcons.wallet,
        label: 'Wallet',
        route: RoutePaths.wallet,
      ),
      BottomNavItem(
        icon: LucideIcons.trendingUp,
        activeIcon: LucideIcons.trendingUp,
        label: 'Portfolio',
        route: RoutePaths.portfolio,
      ),
      BottomNavItem(
        icon: LucideIcons.clipboardList,
        activeIcon: LucideIcons.clipboardList,
        label: 'Tasks',
        route: RoutePaths.tasks,
      ),
      BottomNavItem(
        icon: LucideIcons.user,
        activeIcon: LucideIcons.user,
        label: 'Profile',
        route: RoutePaths.profile,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.background,
        border: Border(
          top: BorderSide(
            color: ShadTheme.of(context).colorScheme.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isActive = _isRouteActive(currentRoute, item.route);

              return _BottomNavButton(
                item: item,
                isActive: isActive,
                onTap: () => context.go(item.route),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  bool _isRouteActive(String currentRoute, String itemRoute) {
    if (itemRoute == RoutePaths.dashboard) {
      return currentRoute == RoutePaths.dashboard || currentRoute == '/';
    }
    return currentRoute.startsWith(itemRoute);
  }
}

class _BottomNavButton extends StatelessWidget {
  final BottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? ShadTheme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 24,
              color: isActive
                  ? ShadTheme.of(context).colorScheme.primary
                  : ShadTheme.of(context).colorScheme.mutedForeground,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: ShadTheme.of(context).textTheme.small?.copyWith(
                color: isActive
                    ? ShadTheme.of(context).colorScheme.primary
                    : ShadTheme.of(context).colorScheme.mutedForeground,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
