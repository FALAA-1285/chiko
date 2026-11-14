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
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Kelompok berdasarkan jarak deadline dari hari ini.
  String _groupOf(Task t, DateTime now) {
    final selisih = tanpaJam(t.dueAt).difference(tanpaJam(now)).inDays;
    if (selisih < 0) return 'Terlambat';
    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Besok';
    if (selisih <= 7) return 'Minggu ini';
    return 'Nanti';
  }

  void _openAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      builder: (context) => const _AddTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = TaskStore.instance;
    return Scaffold(
      floatingActionButton: AddFab(
        tooltip: 'Tambah tugas',
        onPressed: () => _openAddTaskSheet(context),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final now = sekarang();
            final minggu = store.thisWeek(now);
            final selesaiMinggu = minggu.where((t) => t.done).length;
            final source = _showDone ? store.completed : store.active;
            final list = source.where((t) {
              final matchCategory = _filter == null || t.category == _filter;
              final matchQuery = _searchQuery.isEmpty ||
                  t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  (t.groupName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
              return matchCategory && matchQuery;
            }).toList();

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
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearching = false;
                            _searchQuery = '';
                          });
                        },
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

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _groupController = TextEditingController();
  TaskCategory _category = TaskCategory.kuliah;
  Priority _priority = Priority.sedang;
  late DateTime _dueDate = sekarang().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = sekarang();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Tanggal deadline',
    );
    if (picked != null) {
      setState(() => _dueDate = DateTime(picked.year, picked.month, picked.day, _dueDate.hour, _dueDate.minute));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _dueDate.hour, minute: _dueDate.minute),
      helpText: 'Jam deadline',
    );
    if (picked != null) {
      setState(() => _dueDate = DateTime(_dueDate.year, _dueDate.month, _dueDate.day, picked.hour, picked.minute));
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul tugas tidak boleh kosong.')));
      return;
    }
    final group = _groupController.text.trim();
    TaskStore.instance.add(
      title: title,
      category: _category,
      dueAt: _dueDate,
      priority: _priority,
      groupName: group.isEmpty ? null : group,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tugas "$title" berhasil ditambahkan.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Tambah Tugas Baru', style: AppText.display(22, weight: FontWeight.w600))),
                RoundIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Tutup',
                  size: 38,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Judul Tugas', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: Laporan Praktikum PCVK'),
            ),
            const SizedBox(height: 14),
            Text('Mata Kuliah / Proyek (opsional)', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
            const SizedBox(height: 6),
            TextField(
              controller: _groupController,
              textCapitalization: TextCapitalization.words,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: PCVK, Basis Data'),
            ),
            const SizedBox(height: 14),
            Text('Kategori', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in TaskCategory.values)
                  ChoicePill(
                    label: c.label,
                    selected: _category == c,
                    selectedColor: c.ink,
                    selectedText: AppColors.white,
                    onTap: () => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Prioritas', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in Priority.values)
                  ChoicePill(
                    label: p.label,
                    selected: _priority == p,
                    selectedColor: p.color,
                    selectedText: AppColors.white,
                    onTap: () => setState(() => _priority = p),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Deadline', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      backgroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.ink, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size(0, 48),
                    ),
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(tanggalPendek(_dueDate), style: AppText.body(13, weight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      backgroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.ink, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size(0, 48),
                    ),
                    icon: const Icon(Icons.access_time_rounded, size: 18),
                    label: Text(jam(_dueDate), style: AppText.body(13, weight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BoldButton(label: 'Simpan Tugas', onPressed: _save),
          ],
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
