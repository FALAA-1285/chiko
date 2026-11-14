import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/mascot/chiko.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bold.dart';
import '../finance/data/finance_store.dart';

/// Layar Pengaturan dan kelola preferensi.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pengingat = true;
  ChikoMood _mood = ChikoMood.santai;

  void _showAccounts(BuildContext context) {
    final store = FinanceStore.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Daftar Akun', style: AppText.display(22, weight: FontWeight.w600))),
                RoundIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Tutup',
                  size: 38,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final acc in store.accounts) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: acc.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Icon(acc.icon, color: AppColors.ink, size: 20),
                ),
                title: Text(acc.name, style: AppText.body(15, weight: FontWeight.w800)),
                subtitle: Text('Tipe: ${acc.type.name.toUpperCase()}', style: AppText.body(12, color: AppColors.muted)),
                trailing: Text(rupiah(store.balanceOf(acc.id)), style: AppText.body(15, weight: FontWeight.w900)),
              ),
              const Divider(height: 1, color: AppColors.line),
            ],
            const SizedBox(height: 12),
            Center(
              child: Text('Saldo dihitung otomatis dari transaksi kamu.', style: AppText.body(12, color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategories(BuildContext context) {
    final store = FinanceStore.instance;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Kategori Transaksi', style: AppText.display(22, weight: FontWeight.w600))),
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Tutup',
                    size: 38,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('PENGELUARAN', style: AppText.body(12, weight: FontWeight.w900, color: AppColors.muted)),
              const SizedBox(height: 6),
              for (final c in store.categoriesFor(TxnKind.expense))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: c.soft, shape: BoxShape.circle),
                    child: Icon(c.icon, color: c.color, size: 20),
                  ),
                  title: Text(c.name, style: AppText.body(14, weight: FontWeight.w800)),
                ),
              const SizedBox(height: 14),
              Text('PEMASUKAN', style: AppText.body(12, weight: FontWeight.w900, color: AppColors.muted)),
              const SizedBox(height: 6),
              for (final c in store.categoriesFor(TxnKind.income))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: c.soft, shape: BoxShape.circle),
                    child: Icon(c.icon, color: c.color, size: 20),
                  ),
                  title: Text(c.name, style: AppText.body(14, weight: FontWeight.w800)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.ink, width: 2),
        ),
        title: Text('Backup & Restore', style: AppText.display(20)),
        content: Text(
          'Semua data tugas, jadwal, dan keuangan tersimpan secara lokal dan aman di perangkatmu sendiri tanpa perlu akun cloud.',
          style: AppText.body(14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppText.body(14, weight: FontWeight.w800)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data lokal berhasil disinkronkan.')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.ink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.ink, width: 1.5),
              ),
            ),
            child: Text('Backup Sekarang', style: AppText.body(14, weight: FontWeight.w800)),
          ),
        ],
      ),
    );
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ekspresi Chiko: ${_mood.name.toUpperCase()}',
                          style: AppText.body(13, weight: FontWeight.w900, color: AppColors.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ketuk Chiko untuk mencoba ekspresi lainnya!',
                          style: AppText.body(13, weight: FontWeight.w700, height: 1.35, color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _Group(children: [
              _Item(icon: Icons.account_balance_rounded, label: 'Kelola akun', onTap: () => _showAccounts(context)),
              _Item(icon: Icons.category_rounded, label: 'Kelola kategori', onTap: () => _showCategories(context)),
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
              _Item(icon: Icons.backup_rounded, label: 'Backup & restore', onTap: () => _showBackup(context)),
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
