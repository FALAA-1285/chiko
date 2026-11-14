import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/mascot/chiko.dart';
import '../../core/widgets/bold.dart';

class SambutanPage extends StatelessWidget {
  const SambutanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/beranda'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.ink, minimumSize: const Size(44, 44)),
                        child: Text('Lewati', style: AppText.body(15, weight: FontWeight.w800)),
                      ),
                    ),
                    const _Hero(),
                    const SizedBox(height: 12),
                    Text('Halo, aku Chiko!', textAlign: TextAlign.center, style: AppText.display(32)),
                    const SizedBox(height: 10),
                    Text(
                      'Aku bantu kamu ingat tugas kuliah, jadwal, dan uang jajan. Semua tersimpan di HP-mu sendiri.',
                      textAlign: TextAlign.center,
                      style: AppText.body(16, color: AppColors.inkSoft, height: 1.55),
                    ),
                    const SizedBox(height: 18),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FeaturePill(icon: Icons.task_alt_rounded, label: 'Tugas', color: AppColors.kerjaSoft),
                        _FeaturePill(icon: Icons.calendar_month_rounded, label: 'Kalender', color: AppColors.kuliahSoft),
                        _FeaturePill(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan', color: AppColors.incomeSoft),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(height: 20),
                    const _PageDots(),
                    const SizedBox(height: 18),
                    BoldButton(label: 'Mulai', onPressed: () => context.go('/beranda')),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur pulihkan data menyusul di versi berikutnya.')),
                      ),
                      style: TextButton.styleFrom(foregroundColor: AppColors.inkSoft),
                      child: Text('Sudah punya backup? Pulihkan data', style: AppText.body(14, weight: FontWeight.w700, color: AppColors.inkSoft)),
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

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2),
            ),
          ),
          const Positioned(top: 26, right: 40, child: _Bubble(size: 52, color: AppColors.pink)),
          const Positioned(bottom: 40, left: 24, child: _Bubble(size: 32, color: AppColors.kuliahSoft)),
          const Chiko(mood: ChikoMood.santai, size: 290),
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: AppColors.ink, width: 2)),
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

class _PageDots extends StatelessWidget {
  const _PageDots();

  @override
  Widget build(BuildContext context) {
    Widget dot(double w, Color c) => Container(
          width: w,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
        );
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [dot(24, AppColors.ink), dot(8, AppColors.line), dot(8, AppColors.line)],
      ),
    );
  }
}
