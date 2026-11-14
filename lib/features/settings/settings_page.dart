import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/mascot/chiko.dart';
import '../../core/widgets/bold.dart';

/// Kerangka layar Pengaturan. Isi tiap menu dikerjakan setelah database siap.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pengingat = true;
  ChikoMood _mood = ChikoMood.santai;

  void _segera() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu ini menyusul di versi berikutnya.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text('Pengaturan', style: AppText.display(30)),
            const SizedBox(height: 16),
            BoldCard(
              color: AppColors.yellowSoft,
              radius: 24,
              shadow: true,
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  Chiko(
                    mood: _mood,
                    size: 100,
                    onTap: () => setState(() => _mood = ChikoMood.values[(_mood.index + 1) % ChikoMood.values.length]),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Coba ketuk aku! Ekspresiku berganti setiap kali disentuh.',
                      style: AppText.body(14, weight: FontWeight.w700, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _Group(children: [
              _Item(icon: Icons.account_balance_rounded, label: 'Kelola akun', onTap: _segera),
              _Item(icon: Icons.category_rounded, label: 'Kelola kategori', onTap: _segera),
            ]),
            const SizedBox(height: 14),
            _Group(children: [
              SwitchListTile(
                value: _pengingat,
                onChanged: (v) => setState(() => _pengingat = v),
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected) ? AppColors.yellow : AppColors.white,
                ),
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected) ? AppColors.ink : AppColors.line,
                ),
                secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.ink),
                title: Text('Notifikasi pengingat', style: AppText.body(15, weight: FontWeight.w800)),
              ),
              _Item(icon: Icons.backup_rounded, label: 'Backup & restore', onTap: _segera),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return BoldCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1) const Divider(height: 1, thickness: 1.5, indent: 16, endIndent: 16, color: AppColors.line),
            ],
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.ink),
      title: Text(label, style: AppText.body(15, weight: FontWeight.w800)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.ink),
    );
  }
}
