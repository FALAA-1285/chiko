import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/mascot/chiko.dart';
import '../../core/widgets/aksi.dart';
import '../../core/widgets/bold.dart';

class SambutanPage extends StatefulWidget {
  const SambutanPage({super.key});

  @override
  State<SambutanPage> createState() => _SambutanPageState();
}

class _SambutanPageState extends State<SambutanPage> {
  final _nama = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  /// Simpan nama (opsional) dan tandai Sambutan selesai, supaya tidak muncul lagi.
  Future<void> _mulai() async {
    if (_saving) return;
    setState(() => _saving = true);
    final settings = AppScope.of(context).settings;
    final router = GoRouter.of(context);
    final ok = await jalankanAksi(context, () async {
      if (_nama.text.trim().isNotEmpty) await settings.setNamaPengguna(_nama.text);
      await settings.selesaikanOnboarding();
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) router.go('/beranda');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heroSize = (constraints.maxHeight * 0.32).clamp(160.0, 230.0);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _saving ? null : _mulai,
                          style: TextButton.styleFrom(foregroundColor: AppColors.ink, minimumSize: const Size(44, 44)),
                          child: Text('Lewati', style: AppText.body(15, weight: FontWeight.w800)),
                        ),
                      ),
                      _Hero(size: heroSize),
                      const SizedBox(height: 10),
                      Text('Halo, aku Chiko!', textAlign: TextAlign.center, style: AppText.display(28)),
                      const SizedBox(height: 8),
                      Text(
                        'Aku bantu kamu ingat tugas kuliah, jadwal, dan uang jajan. Semua tersimpan di HP-mu sendiri.',
                        textAlign: TextAlign.center,
                        style: AppText.body(15, color: AppColors.inkSoft, height: 1.45),
                      ),
                      const SizedBox(height: 14),
                      const Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FeaturePill(icon: Icons.task_alt_rounded, label: 'Tugas', color: AppColors.kerjaSoft),
                          _FeaturePill(
                              icon: Icons.calendar_month_rounded, label: 'Kalender', color: AppColors.kuliahSoft),
                          _FeaturePill(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Keuangan',
                              color: AppColors.incomeSoft),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nama,
                        maxLength: 30,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _mulai(),
                        style: AppText.body(15),
                        decoration: const InputDecoration(
                          labelText: 'Mau dipanggil apa? (opsional)',
                          hintText: 'Misal: Ahmad',
                          counterText: '',
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
                      BoldButton(label: _saving ? 'Menyiapkan…' : 'Mulai', onPressed: _saving ? null : _mulai),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({this.size = 220});

  final double size;

  @override
  Widget build(BuildContext context) {
    final circleSize = size * 0.9;
    return SizedBox(
      height: size + 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
          ),
          Positioned(top: size * 0.08, right: size * 0.12, child: _Bubble(size: size * 0.18, color: AppColors.pink)),
          Positioned(
              bottom: size * 0.12, left: size * 0.08, child: _Bubble(size: size * 0.12, color: AppColors.kuliahSoft)),
          Chiko(mood: ChikoMood.santai, size: size),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: AppColors.ink, width: 2)),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.ink),
          const SizedBox(width: 6),
          Text(label, style: AppText.body(13, weight: FontWeight.w800)),
        ],
      ),
    );
  }
}
