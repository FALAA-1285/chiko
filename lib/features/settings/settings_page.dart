import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/mascot/chiko.dart';
import '../../core/widgets/aksi.dart';
import '../../core/widgets/bold.dart';
import 'kelola_keuangan.dart';
import 'settings_store.dart';

/// Layar Pengaturan dan kelola preferensi.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ChikoMood _mood = ChikoMood.santai;

  Future<void> _ubahNama(SettingsStore settings) async {
    final hasil = await showDialog<String>(
      context: context,
      builder: (_) => _NamaDialog(awal: settings.namaPengguna),
    );
    if (hasil == null || !mounted) return;
    await jalankanAksi(context, () => settings.setNamaPengguna(hasil), pesanSukses: 'Nama disimpan.');
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => ListView(
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
                      onTap: () =>
                          setState(() => _mood = ChikoMood.values[(_mood.index + 1) % ChikoMood.values.length]),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.namaPengguna.isEmpty ? 'Halo!' : 'Halo, ${settings.namaPengguna}!',
                            style: AppText.display(18, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ketuk Chiko untuk melihat ekspresi lainnya.',
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
                _Item(
                  icon: Icons.badge_rounded,
                  label: 'Nama panggilan',
                  value: settings.namaPengguna.isEmpty ? 'Belum diisi' : settings.namaPengguna,
                  onTap: () => _ubahNama(settings),
                ),
              ]),
              const SizedBox(height: 14),
              _Group(children: [
                _Item(icon: Icons.account_balance_rounded, label: 'Kelola akun', onTap: () => bukaKelolaAkun(context)),
                _Item(icon: Icons.category_rounded, label: 'Kelola kategori', onTap: () => bukaKelolaKategori(context)),
              ]),
              const SizedBox(height: 14),
              BoldCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.phone_android_rounded, color: AppColors.ink),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data tersimpan di perangkat ini', style: AppText.body(15, weight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                            'Tugas, jadwal, dan keuanganmu disimpan di HP ini saja, tanpa akun online. '
                            'Data akan hilang bila aplikasi dihapus.',
                            style: AppText.body(13, color: AppColors.inkSoft, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NamaDialog extends StatefulWidget {
  const _NamaDialog({required this.awal});

  final String awal;

  @override
  State<_NamaDialog> createState() => _NamaDialogState();
}

class _NamaDialogState extends State<_NamaDialog> {
  late final _controller = TextEditingController(text: widget.awal);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nama panggilan', style: AppText.display(20, weight: FontWeight.w600)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: SettingsStore.maxPanjangNama,
        textCapitalization: TextCapitalization.words,
        style: AppText.body(15),
        decoration: const InputDecoration(hintText: 'Misal: Ahmad'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal', style: AppText.body(14, weight: FontWeight.w800, color: AppColors.muted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text('Simpan', style: AppText.body(14, weight: FontWeight.w900)),
        ),
      ],
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
              if (i < children.length - 1)
                const Divider(height: 1, thickness: 1.5, indent: 16, endIndent: 16, color: AppColors.line),
            ],
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.onTap, this.value});

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.ink),
      title: Text(label, style: AppText.body(15, weight: FontWeight.w800)),
      subtitle: value == null ? null : Text(value!, style: AppText.body(13, color: AppColors.muted)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.ink),
    );
  }
}
