import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/aksi.dart';
import '../../../core/widgets/bold.dart';
import '../data/task_store.dart';
import 'task_style.dart';

/// Membuka form tugas: tambah baru (tanpa [task]) atau lihat/ubah/hapus tugas yang ada.
Future<void> bukaFormTugas(BuildContext context, {Task? task}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _TaskSheet(task: task),
  );
}

class _TaskSheet extends StatefulWidget {
  const _TaskSheet({this.task});

  final Task? task;

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  late final _titleController = TextEditingController(text: widget.task?.title);
  late final _groupController = TextEditingController(text: widget.task?.groupName);
  late TaskCategory _category = widget.task?.category ?? TaskCategory.kuliah;
  late Priority _priority = widget.task?.priority ?? Priority.sedang;
  late DateTime _dueDate = widget.task?.dueAt ?? _besokJamSama();

  /// Tanggal mulai opsional: bila aktif, tugas tampil sebagai blok di Kalender.
  late bool _punyaMulai = widget.task?.hasSpan ?? false;
  late DateTime _startDate = widget.task?.startAt ?? tanpaJam(sekarang());
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  static DateTime _besokJamSama() {
    final now = sekarang();
    return DateTime(now.year, now.month, now.day + 1, 23, 59);
  }

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
    if (picked == null) return;
    setState(() {
      _dueDate = DateTime(picked.year, picked.month, picked.day, _dueDate.hour, _dueDate.minute);
      // Jaga supaya tanggal mulai tidak melewati deadline.
      if (selisihHari(_startDate, _dueDate) < 0) _startDate = tanpaJam(_dueDate);
    });
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

  Future<void> _pickStartDate() async {
    final now = sekarang();
    final last = tanpaJam(_dueDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isAfter(last) ? last : _startDate,
      firstDate: DateTime(now.year - 1),
      lastDate: last,
      helpText: 'Tanggal mulai',
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _save() async {
    if (_saving) return; // cegah simpan dua kali
    setState(() => _saving = true);
    final store = AppScope.of(context).tasks;
    final title = _titleController.text.trim();
    final navigator = Navigator.of(context);
    final ok = await jalankanAksi(
      context,
      () async {
        if (_isEdit) {
          await store.update(widget.task!.copyWith(
            title: title,
            category: _category,
            priority: _priority,
            dueAt: _dueDate,
            startAt: () => _punyaMulai ? _startDate : null,
            groupName: () => _groupController.text,
          ));
        } else {
          await store.add(
            title: title,
            category: _category,
            dueAt: _dueDate,
            startAt: _punyaMulai ? _startDate : null,
            priority: _priority,
            groupName: _groupController.text,
          );
        }
      },
      pesanSukses: _isEdit ? 'Tugas "$title" disimpan.' : 'Tugas "$title" berhasil ditambahkan.',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) navigator.pop();
  }

  Future<void> _delete() async {
    final task = widget.task!;
    final store = AppScope.of(context).tasks;
    final navigator = Navigator.of(context);
    final ok = await jalankanAksi(
      context,
      () => store.remove(task),
      pesanSukses: 'Tugas "${task.title}" dihapus.',
      onUndo: () => store.restore(task),
    );
    if (ok && mounted) navigator.pop();
  }

  ButtonStyle get _pickerStyle => OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.ink, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(0, 48),
      );

  Widget _label(String text) => Text(text, style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted));

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final rentangSalah = _punyaMulai && selisihHari(_startDate, _dueDate) < 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_isEdit ? 'Ubah Tugas' : 'Tambah Tugas Baru',
                      style: AppText.display(22, weight: FontWeight.w600)),
                ),
                if (_isEdit) ...[
                  RoundIconButton(
                      icon: Icons.delete_outline_rounded, tooltip: 'Hapus tugas', size: 44, onPressed: _delete),
                  const SizedBox(width: 8),
                ],
                RoundIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Tutup',
                  size: 44,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Judul Tugas'),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              autofocus: !_isEdit,
              maxLength: TaskStore.maxPanjangJudul,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: Laporan Praktikum PCVK', counterText: ''),
            ),
            const SizedBox(height: 14),
            _label('Mata Kuliah / Proyek (opsional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _groupController,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: PCVK, Basis Data', counterText: ''),
            ),
            const SizedBox(height: 14),
            _label('Kategori'),
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
            _label('Prioritas'),
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
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _punyaMulai,
              onChanged: (v) => setState(() {
                _punyaMulai = v;
                if (v && selisihHari(_startDate, _dueDate) < 0) _startDate = tanpaJam(_dueDate);
              }),
              activeThumbColor: AppColors.yellow,
              title: Text('Atur tanggal mulai', style: AppText.body(14, weight: FontWeight.w800)),
              subtitle: Text('Tampil sebagai blok mulai–selesai di Kalender',
                  style: AppText.body(12, color: AppColors.muted)),
            ),
            if (_punyaMulai) ...[
              const SizedBox(height: 4),
              _label('Mulai'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  style: _pickerStyle,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(tanggalPendek(_startDate), style: AppText.body(13, weight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 14),
            ] else
              const SizedBox(height: 4),
            _label(_punyaMulai ? 'Selesai (deadline)' : 'Deadline'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    style: _pickerStyle,
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(tanggalPendek(_dueDate), style: AppText.body(13, weight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    style: _pickerStyle,
                    icon: const Icon(Icons.access_time_rounded, size: 18),
                    label: Text(jam(_dueDate), style: AppText.body(13, weight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            if (_punyaMulai) ...[
              const SizedBox(height: 8),
              Text(
                rentangSalah
                    ? 'Tanggal mulai melewati deadline.'
                    : 'Durasi ${selisihHari(_startDate, _dueDate) + 1} hari · ${rentangTanggal(_startDate, _dueDate)}',
                style: AppText.body(12,
                    weight: FontWeight.w700, color: rentangSalah ? AppColors.expenseInk : AppColors.inkSoft),
              ),
            ],
            if (_isEdit && widget.task!.done) ...[
              const SizedBox(height: 10),
              Text(
                'Selesai ${tanggalPendek(widget.task!.completedAt!)}, ${jam(widget.task!.completedAt!)}',
                style: AppText.body(12, weight: FontWeight.w700, color: AppColors.incomeInk),
              ),
            ],
            const SizedBox(height: 20),
            BoldButton(
              label: _saving ? 'Menyimpan…' : (_isEdit ? 'Simpan Perubahan' : 'Simpan Tugas'),
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
