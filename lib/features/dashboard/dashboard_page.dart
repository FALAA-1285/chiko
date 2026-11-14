import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/mascot/chiko.dart';
import '../../core/mascot/chiko_mood.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bold.dart';
import '../calendar/data/event_store.dart';
import '../calendar/ui/widgets/event_tile.dart';
import '../finance/data/finance_store.dart';
import '../tasks/data/task_store.dart';
import '../tasks/ui/widgets/task_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = TaskStore.instance;
    final finance = FinanceStore.instance;
    final events = EventStore.instance;

    return Scaffold(
      floatingActionButton: AddFab(
        tooltip: 'Tambah transaksi',
        onPressed: () => context.push('/tambah-transaksi'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([tasks, finance, events]),
          builder: (context, _) {
            final now = sekarang();
            final status = hitungMood(now: now, tasks: tasks, finance: finance);
            final jadwal = events.scheduleOn(now);
            final terdekat = tasks.active.take(3).toList();
            final bulanIni = DateTime(now.year, now.month);
            final masuk = finance.incomeInMonth(bulanIni);
            final keluar = finance.expenseInMonth(bulanIni);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                _Header(now: now),
                const SizedBox(height: 18),
                _ChikoCard(status: status),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _StatTile(value: '${jadwal.length}', label: 'jadwal hari ini', color: AppColors.kuliahSoft, ink: AppColors.kuliahInk)),
                    const SizedBox(width: 10),
                    Expanded(child: _StatTile(value: '${tasks.active.length}', label: 'tugas aktif', color: AppColors.kerjaSoft, ink: AppColors.kerjaInk)),
                    const SizedBox(width: 10),
                    Expanded(child: _StatTile(value: rupiahSingkat(finance.expenseOn(now)), label: 'keluar hari ini', color: AppColors.expenseSoft, ink: AppColors.expenseInk)),
                  ],
                ),
                const SizedBox(height: 20),
                SectionHeader(title: 'Jadwal hari ini', action: 'Kalender', onAction: () => context.go('/kalender')),
                const SizedBox(height: 4),
                if (jadwal.isEmpty)
                  Text('Tidak ada jadwal hari ini.', style: AppText.body(15, color: AppColors.inkSoft))
                else
                  for (final e in jadwal) ...[
                    EventTile(event: e),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 10),
                SectionHeader(title: 'Tugas terdekat', action: 'Semua tugas', onAction: () => context.go('/tugas')),
                const SizedBox(height: 4),
                BoldCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: terdekat.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text('Semua tugas sudah beres.', style: AppText.body(15, color: AppColors.inkSoft)),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < terdekat.length; i++) ...[
                              TaskTile(task: terdekat[i], now: now, boxed: false, onToggle: () => tasks.toggle(terdekat[i])),
                              if (i < terdekat.length - 1) const Divider(height: 1, thickness: 1.5, color: AppColors.line),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                SectionHeader(title: 'Uangmu bulan ini', action: 'Detail', onAction: () => context.go('/keuangan')),
                const SizedBox(height: 4),
                _MoneyCard(total: finance.totalBalance, accounts: finance.accounts.length, masuk: masuk, keluar: keluar),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.now});

  final DateTime now;

  void _showNotifications(BuildContext context) {
    final tasks = TaskStore.instance;
    final mepet = tasks.active.where((t) => t.isUrgent(now)).toList();
    final selesai = tasks.completedOn(now);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Notifikasi & Pengingat', style: AppText.display(22, weight: FontWeight.w600))),
                RoundIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Tutup',
                  size: 38,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (mepet.isEmpty && selesai.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('Belum ada notifikasi baru hari ini.', style: AppText.body(15, color: AppColors.inkSoft)),
                ),
              )
            else ...[
              for (final t in mepet) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.expenseSoft,
                    child: Icon(Icons.warning_amber_rounded, color: AppColors.expenseInk),
                  ),
                  title: Text(t.title, style: AppText.body(15, weight: FontWeight.w800)),
                  subtitle: Text('Deadline: ${labelDeadline(t.dueAt, now)}', style: AppText.body(13, color: AppColors.muted)),
                ),
                const Divider(height: 1, color: AppColors.line),
              ],
              for (final t in selesai) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.incomeSoft,
                    child: Icon(Icons.check_circle_rounded, color: AppColors.incomeInk),
                  ),
                  title: Text(t.title, style: AppText.body(15, weight: FontWeight.w800)),
                  subtitle: Text('Selesai hari ini', style: AppText.body(13, color: AppColors.incomeInk)),
                ),
                const Divider(height: 1, color: AppColors.line),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tanggalPanjang(now), style: AppText.body(14, weight: FontWeight.w700, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text('Halo, $namaPengguna!', style: AppText.display(30)),
            ],
          ),
        ),
        RoundIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifikasi',
          badge: true,
          onPressed: () => _showNotifications(context),
        ),
      ],
    );
  }
}

class _ChikoCard extends StatelessWidget {
  const _ChikoCard({required this.status});

  final ChikoStatus status;

  @override
  Widget build(BuildContext context) {
    return BoldCard(
      color: AppColors.yellow,
      radius: 26,
      shadow: true,
      padding: const EdgeInsets.fromLTRB(6, 12, 16, 14),
      child: Row(
        children: [
          Chiko(mood: status.mood, size: 114),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.ink, width: 2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(status.message, style: AppText.body(14, weight: FontWeight.w700, height: 1.4)),
                ),
                if (status.action != null) ...[
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.go(status.route!),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: AppText.body(14, weight: FontWeight.w800),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Text(status.action!, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.color, required this.ink});

  final String value;
  final String label;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return BoldCard(
      color: color,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.display(24)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(12, weight: FontWeight.w700, color: ink),
          ),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.total, required this.accounts, required this.masuk, required this.keluar});

  final int total;
  final int accounts;
  final int masuk;
  final int keluar;

  @override
  Widget build(BuildContext context) {
    final terpakai = masuk == 0 ? 0.0 : keluar / masuk;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total saldo · $accounts akun', style: AppText.body(13, weight: FontWeight.w700, color: AppColors.darkMuted)),
          const SizedBox(height: 2),
          Text(rupiah(total), style: AppText.display(30, color: AppColors.yellow)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _DarkStat(label: 'Masuk', value: '+${rupiah(masuk)}', color: AppColors.incomeOnDark)),
              const SizedBox(width: 10),
              Expanded(child: _DarkStat(label: 'Keluar', value: '−${rupiah(keluar)}', color: AppColors.expenseOnDark)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: terpakai.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFF3A3A3A),
              color: AppColors.yellow,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(terpakai * 100).round()}% pemasukan sudah terpakai',
            style: AppText.body(12, weight: FontWeight.w700, color: AppColors.darkMuted),
          ),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, weight: FontWeight.w700, color: AppColors.darkMuted)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.body(16, weight: FontWeight.w900, color: color)),
          ),
        ],
      ),
    );
  }
}
