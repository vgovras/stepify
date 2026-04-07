import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/core.dart';

/// Bottom navigation scaffold used by [ShellRoute].
///
/// Wraps Home, Shopping, and Profile screens with a persistent
/// bottom navigation bar. Cook flow screens are outside this shell.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xF5_0E0D0B),
          border: Border(top: BorderSide(color: AppColors.br)),
        ),
        padding: const EdgeInsets.only(bottom: 20, top: 8),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Головна',
              isActive: navigationShell.currentIndex == 0,
              onTap: () => navigationShell.goBranch(0),
            ),
            _NavItem(
              icon: Icons.search_rounded,
              label: 'Пошук',
              isActive: navigationShell.currentIndex == 1,
              onTap: () => navigationShell.goBranch(1),
            ),
            _NavItem(
              icon: Icons.shopping_cart_rounded,
              label: 'Покупки',
              isActive: navigationShell.currentIndex == 2,
              onTap: () => navigationShell.goBranch(2),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Профіль',
              isActive: navigationShell.currentIndex == 3,
              onTap: () => navigationShell.goBranch(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.ac : AppColors.t3,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.ac : AppColors.t3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
