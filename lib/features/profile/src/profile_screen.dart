import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/core.dart';
import '../../../shared_ui/shared_ui.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';

const _monthNames = [
  'січень',
  'лютий',
  'березень',
  'квітень',
  'травень',
  'червень',
  'липень',
  'серпень',
  'вересень',
  'жовтень',
  'листопад',
  'грудень',
];

String _formatJoinDate(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.year}';

/// User profile screen — avatar, stats, and menu items.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHorizontal,
                vertical: 16,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const _Avatar(),
                  const SizedBox(height: 16),
                  Text(
                    state.userName,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tx,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Кулінар-ентузіаст \u{00B7}'
                    ' ${_formatJoinDate(DateTime.now())}',
                    style: const TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: AppColors.t3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  StatGrid(
                    cells: [
                      StatCell(
                        value: '${state.cookedCount}',
                        label: 'Приготовлено',
                      ),
                      StatCell(
                        value: '${state.savedCount}',
                        label: 'Збережено',
                      ),
                      const StatCell(value: '0', label: 'Мої рецепти'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ..._menuItems(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _menuItems(BuildContext context) {
    const items = [
      _MenuData(
        icon: Icons.restaurant_menu,
        title: 'Мої рецепти',
        trailing: '0',
      ),
      _MenuData(
        icon: Icons.bookmark_outline,
        title: 'Збережені',
        trailing: '0',
      ),
      _MenuData(icon: Icons.check_circle_outline, title: 'Приготовлені'),
      _MenuData(icon: Icons.add_circle_outline, title: 'Додати рецепт'),
      _MenuData(icon: Icons.settings_outlined, title: 'Налаштування'),
    ];

    return items
        .map(
          (data) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MenuItem(
              data: data,
              onTap: () => showAppToast(context, 'Незабаром...'),
            ),
          ),
        )
        .toList();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ac, AppColors.ac2],
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        '\u{1F468}\u{200D}\u{1F373}',
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

class _MenuData {
  const _MenuData({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final String? trailing;
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.data, required this.onTap});

  final _MenuData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.cardPadding,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.s1,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.br),
        ),
        child: Row(
          children: [
            Icon(data.icon, size: 20, color: AppColors.t2),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.title,
                style: const TextStyle(
                  fontSize: AppSizes.fontMain,
                  color: AppColors.tx,
                ),
              ),
            ),
            if (data.trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.s2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data.trailing!,
                  style: const TextStyle(
                    fontSize: AppSizes.fontLabel,
                    color: AppColors.t2,
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right, size: 18, color: AppColors.t3),
          ],
        ),
      ),
    );
  }
}
