import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../core/core.dart';
import '../shared_ui/shared_ui.dart';

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
              svgAsset: AppIcons.house,
              label: 'Головна',
              isActive: navigationShell.currentIndex == 0,
              onTap: () => navigationShell.goBranch(0),
            ),
            _NavItem(
              svgAsset: AppIcons.magnifyingGlass,
              label: 'Пошук',
              isActive: navigationShell.currentIndex == 1,
              onTap: () => navigationShell.goBranch(1),
            ),
            _NavItem(
              svgAsset: AppIcons.shoppingCart,
              label: 'Покупки',
              isActive: navigationShell.currentIndex == 2,
              onTap: () => navigationShell.goBranch(2),
            ),
            _NavItem(
              svgAsset: AppIcons.bustInSilhouette,
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
    required this.svgAsset,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String svgAsset;
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
            SvgPicture.asset(svgAsset, width: 24, height: 24),
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
