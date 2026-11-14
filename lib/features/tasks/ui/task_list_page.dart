import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/mascot/chiko.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bold.dart';
import '../data/task_store.dart';
import 'widgets/task_tile.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskCategory? _filter;
  bool _showDone = false;

  /// Kelompok berdasarkan jarak deadline dari hari ini.
  String _groupOf(Task t, DateTime now) {
    final selisih = tanpaJam(t.dueAt).difference(tanpaJam(now)).inDays;
    if (selisih < 0) return 'Terlambat';
    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Besok';
    if (selisih <= 7) return 'Minggu ini';
    return 'Nanti';
  }

  @override
  Widget build(BuildContext context) {
    final store = TaskStore.instance;
    return Scaffold(
      floatingActionButton: AddFab(
        tooltip: 'Tambah tugas',
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form tambah tugas menyusul.')),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final now = sekarang();
            final minggu = store.thisWeek(now);
            final selesaiMinggu = minggu.where((t) => t.done).length;
            final source = _showDone ? store.completed : store.active;
            final list = source.where((t) => _filter == null || t.category == _filter).toList();

            final groups = <String, List<Task>>{};
            if (_showDone) {
              if (list.isNotEmpty) groups['Sudah selesai'] = list;
            } else {
              for (final t in list) {
                groups.putIfAbsent(_groupOf(t, now), () => []).add(t);
              }
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Tugas', style: AppText.display(30))),
                    RoundIconButton(icon: Icons.search_rounded, tooltip: 'Cari tugas', onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 16),
                _ProgressCard(done: selesaiMinggu, total: minggu.length),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoicePill(label: 'Semua', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                      for (final c in TaskCategory.values) ...[
                        const SizedBox(width: 8),
                        ChoicePill(label: c.label, selected: _filter == c, onTap: () => setState(() => _filter = c)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SegmentedPills(
                  labels: ['Aktif · ${store.active.length}', 'Selesai · ${store.completed.length}'],
                  selectedIndex: _showDone ? 1 : 0,
                  onChanged: (i) => setState(() => _showDone = i == 1),
                ),
                const SizedBox(height: 18),
                if (groups.isEmpty)
                  _EmptyState(showDone: _showDone)
                else
                  for (final entry in groups.entries) ...[
                    Text(
                      entry.key.toUpperCase(),
                      style: AppText.body(13, weight: FontWeight.w900, color: AppColors.muted).copyWith(letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 8),
                    for (final t in entry.value) ...[
                      TaskTile(task: t, now: now, onToggle: () => store.toggle(t)),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final semua = total > 0 && done == total;
    final sisa = total - done;
    return BoldCard(
      color: AppColors.yellowSoft,
      radius: 24,
      shadow: true,
      padding: const EdgeInsets.fromLTRB(4, 10, 16, 12),
      child: Row(
        children: [
          Chiko(mood: semua ? ChikoMood.rayakan : ChikoMood.senang, size: 104),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$done dari $total tugas minggu ini selesai', style: AppText.display(18, weight: FontWeight.w600)),
                const SizedBox(height: 8),
                BoldProgressBar(value: total == 0 ? 0 : done / total),
                const SizedBox(height: 8),
                Text(
                  semua ? 'Semua beres. Waktunya santai!' : 'Sisa $sisa lagi. Satu-satu saja, ya!',
                  style: AppText.body(13, weight: FontWeight.w700, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.showDone});

  final bool showDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Chiko(mood: showDone ? ChikoMood.santai : ChikoMood.rayakan, size: 150),
          const SizedBox(height: 8),
          Text(
            showDone ? 'Belum ada tugas yang selesai di kategori ini.' : 'Tidak ada tugas di sini. Kamu bebas!',
            textAlign: TextAlign.center,
            style: AppText.body(15, weight: FontWeight.w700, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
