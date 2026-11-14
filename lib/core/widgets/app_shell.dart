import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

/// Kerangka 5 tab dengan navigasi bawah bergaya Chiko.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = <(IconData, String)>[
    (Icons.home_rounded, 'Beranda'),
    (Icons.task_alt_rounded, 'Tugas'),
    (Icons.calendar_month_rounded, 'Kalender'),
    (Icons.account_balance_wallet_rounded, 'Keuangan'),
    (Icons.tune_rounded, 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      // Tinggi bilah tetap, jadi skala teks dibatasi supaya label tidak terpotong.
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 66,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      Expanded(
                        child: _NavItem(
                          icon: _items[i].$1,
                          label: _items[i].$2,
                          selected: navigationShell.currentIndex == i,
                          onTap: () => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? AppColors.yellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? AppColors.ink : Colors.transparent, width: 2),
                ),
                child: Icon(icon, size: 22, color: AppColors.ink),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(11, weight: selected ? FontWeight.w900 : FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
