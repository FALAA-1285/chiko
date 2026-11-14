import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../core/mascot/chiko.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/aksi.dart';
import '../../../core/widgets/bold.dart';
import '../../../core/widgets/swipe_to_delete.dart';
import '../data/task_store.dart';
import 'task_sheet.dart';
import 'widgets/task_tile.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskCategory? _filter;
  bool _showDone = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Kelompok berdasarkan deadline: Terlambat, Hari ini, Besok, Minggu ini (s.d. Minggu), Nanti.
  String _groupOf(Task t, DateTime now) {
    if (t.isOverdue(now)) return 'Terlambat';
    final selisih = selisihHari(now, t.dueAt);
    if (selisih <= 0) return 'Hari ini';
    if (selisih == 1) return 'Besok';
    if (selisih <= 7 - now.weekday) return 'Minggu ini';
    return 'Nanti';
  }

  bool _cocok(String text) => _searchQuery.isEmpty || text.toLowerCase().contains(_searchQuery.toLowerCase());

  Future<void> _deleteTask(TaskStore store, Task t) => jalankanAksi(
        context,
        () => store.remove(t),
        pesanSukses: 'Tugas "${t.title}" dihapus.',
        onUndo: () => store.restore(t),
      );

  void _stopSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).tasks;
    return Scaffold(
      floatingActionButton: AddFab(tooltip: 'Tambah tugas', onPressed: () => bukaFormTugas(context)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final now = sekarang();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                if (_isSearching)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: AppText.body(15),
                          decoration: InputDecoration(
                            hintText: 'Cari tugas...',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.ink),
                            suffixIcon: IconButton(
                              tooltip: 'Hapus pencarian',
                              icon: const Icon(Icons.clear_rounded, color: AppColors.ink),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _stopSearch,
                        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                        child: Text('Batal', style: AppText.body(14, weight: FontWeight.w800)),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: Text('Tugas', style: AppText.display(30))),
                      RoundIconButton(
                        icon: Icons.search_rounded,
                        tooltip: 'Cari tugas',
                        onPressed: () => setState(() => _isSearching = true),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                ..._buildTaskView(store, now),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildTaskView(TaskStore store, DateTime now) {
    final minggu = store.thisWeek(now);
    final selesaiMinggu = minggu.where((t) => t.done).length;
    final terlambat = store.active.where((t) => t.isOverdue(now)).length;
    final source = _showDone ? store.completed : store.active;
    final list = source.where((t) {
      final matchCategory = _filter == null || t.category == _filter;
      return matchCategory && (_cocok(t.title) || _cocok(t.groupName ?? ''));
    }).toList();

    final groups = <String, List<Task>>{};
    if (_showDone) {
      if (list.isNotEmpty) groups['Sudah selesai'] = list;
    } else {
      for (final t in list) {
        groups.putIfAbsent(_groupOf(t, now), () => []).add(t);
      }
    }

    return [
      _ProgressCard(done: selesaiMinggu, total: minggu.length, overdue: terlambat),
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
        _EmptyState(
          mood: _showDone || _searchQuery.isNotEmpty || store.all.isEmpty ? ChikoMood.santai : ChikoMood.rayakan,
          message: _searchQuery.isNotEmpty
              ? 'Tidak ada tugas yang cocok dengan "$_searchQuery".'
              : store.all.isEmpty
                  ? 'Belum ada tugas. Ketuk tombol + untuk menambah tugas pertamamu.'
                  : _showDone
                      ? 'Belum ada tugas yang selesai di kategori ini.'
                      : 'Tidak ada tugas di sini. Kamu bebas!',
        )
      else ...[
        for (final entry in groups.entries) ...[
          _GroupLabel(entry.key, color: entry.key == 'Terlambat' ? AppColors.expenseInk : AppColors.muted),
          const SizedBox(height: 8),
          for (final t in entry.value) ...[
            SwipeToDelete(
              key: ValueKey('task-${t.id}'),
              radius: 18,
              label: 'Hapus tugas ${t.title}',
              onDelete: () => _deleteTask(store, t),
              child: TaskTile(
                task: t,
                now: now,
                onToggle: () => jalankanAksi(context, () => store.toggle(t)),
                onOpen: () => bukaFormTugas(context, task: t),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
        ],
        const _Hint('Ketuk tugas untuk mengubah. Geser ke kiri untuk menghapus.'),
      ],
    ];
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text, {this.color = AppColors.muted});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: AppText.body(13, weight: FontWeight.w900, color: color).copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, textAlign: TextAlign.center, style: AppText.body(12, color: AppColors.muted)),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total, this.overdue = 0});

  final int done;
  final int total;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    final kosong = total == 0;
    final semua = !kosong && done == total;
    final sisa = total - done;
    final judul = kosong ? 'Tidak ada deadline minggu ini' : '$done dari $total tugas minggu ini selesai';
    final pesan = overdue > 0
        ? '$overdue tugas sudah lewat deadline. Kerjakan itu dulu, ya!'
        : kosong
            ? 'Minggu yang lega. Pakai buat istirahat atau mencicil.'
            : semua
                ? 'Semua beres. Waktunya santai!'
                : 'Sisa $sisa lagi. Satu-satu saja, ya!';
    final mood = overdue > 0
        ? ChikoMood.khawatir
        : semua
            ? ChikoMood.rayakan
            : kosong
                ? ChikoMood.santai
                : ChikoMood.senang;
    return BoldCard(
      color: AppColors.yellowSoft,
      radius: 24,
      shadow: true,
      padding: const EdgeInsets.fromLTRB(4, 10, 16, 12),
      child: Row(
        children: [
          Chiko(mood: mood, size: 104),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: AppText.display(18, weight: FontWeight.w600)),
                const SizedBox(height: 8),
                BoldProgressBar(value: kosong ? 0 : done / total),
                const SizedBox(height: 8),
                Text(
                  pesan,
                  style: AppText.body(13,
                      weight: FontWeight.w700, color: overdue > 0 ? AppColors.expenseInk : AppColors.inkSoft),
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
  const _EmptyState({required this.mood, required this.message});

  final ChikoMood mood;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Chiko(mood: mood, size: 150),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.body(15, weight: FontWeight.w700, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
