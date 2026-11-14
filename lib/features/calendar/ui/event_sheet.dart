import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/aksi.dart';
import '../../../core/widgets/bold.dart';
import '../data/event_store.dart';
import 'event_style.dart';

/// Membuka form jadwal: tambah baru di [tanggal], atau ubah/hapus [entry].
Future<void> bukaFormJadwal(BuildContext context, {DateTime? tanggal, ScheduleEntry? entry}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _EventSheet(initialDate: tanggal ?? tanpaJam(sekarang()), entry: entry),
  );
}

class _EventSheet extends StatefulWidget {
  const _EventSheet({required this.initialDate, this.entry});

  final DateTime initialDate;
  final ScheduleEntry? entry;

  @override
  State<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<_EventSheet> {
  late final _titleController = TextEditingController(text: widget.entry?.title);
  late final _placeController = TextEditingController(text: widget.entry?.place);
  late EventType _type = widget.entry?.type ?? EventType.kuliah;
  late DateTime _date = widget.entry == null ? widget.initialDate : tanpaJam(widget.entry!.start);
  late TimeOfDay _startTime =
      widget.entry == null ? const TimeOfDay(hour: 9, minute: 0) : TimeOfDay.fromDateTime(widget.entry!.start);
  late TimeOfDay _endTime =
      widget.entry == null ? const TimeOfDay(hour: 11, minute: 0) : TimeOfDay.fromDateTime(widget.entry!.end);
  late bool _repeatWeekly = widget.entry?.repeatWeekly ?? false;
  late DateTime _repeatUntil = widget.entry?.repeatUntil ?? _akhirBawaan(_date);
  bool _saving = false;

  bool get _isEdit => widget.entry != null;

  /// Bawaan: 16 pertemuan mingguan (satu semester).
  static DateTime _akhirBawaan(DateTime mulai) =>
      DateTime(mulai.year, mulai.month, mulai.day + 7 * (EventStore.mingguPengulanganBawaan - 1));

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = sekarang();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Tanggal acara',
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      if (_repeatUntil.isBefore(_date)) _repeatUntil = _akhirBawaan(_date);
    });
  }

  Future<void> _pickRepeatUntil() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _repeatUntil.isBefore(_date) ? _date : _repeatUntil,
      firstDate: _date,
      lastDate: DateTime(_date.year + 2),
      helpText: 'Ulangi sampai',
    );
    if (picked != null) setState(() => _repeatUntil = picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
      helpText: start ? 'Jam mulai' : 'Jam selesai',
    );
    if (picked == null) return;
    setState(() => start ? _startTime = picked : _endTime = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final store = AppScope.of(context).events;
    final navigator = Navigator.of(context);
    final title = _titleController.text.trim();
    final ok = await jalankanAksi(
      context,
      () => store.save(
        title: title,
        type: _type,
        start: DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute),
        end: DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute),
        place: _placeController.text,
        repeatWeekly: _repeatWeekly,
        repeatUntil: _repeatWeekly ? _repeatUntil : null,
        editingId: widget.entry?.id,
      ),
      pesanSukses: _isEdit ? 'Jadwal "$title" disimpan.' : 'Jadwal "$title" berhasil ditambahkan.',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) navigator.pop();
  }

  Future<void> _delete() async {
    final entry = widget.entry!;
    final store = AppScope.of(context).events;
    final navigator = Navigator.of(context);
    final ok = await jalankanAksi(
      context,
      () => store.remove(entry),
      pesanSukses: entry.repeatWeekly
          ? 'Jadwal "${entry.title}" (semua pertemuan) dihapus.'
          : 'Jadwal "${entry.title}" dihapus.',
      onUndo: () => store.restore(entry),
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
    const availableTypes = [EventType.kuliah, EventType.kerja, EventType.pribadi];
    final jamSalah = (_endTime.hour * 60 + _endTime.minute) <= (_startTime.hour * 60 + _startTime.minute);

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
                  child: Text(_isEdit ? 'Ubah Jadwal' : 'Tambah Jadwal Baru',
                      style: AppText.display(22, weight: FontWeight.w600)),
                ),
                if (_isEdit) ...[
                  RoundIconButton(
                      icon: Icons.delete_outline_rounded, tooltip: 'Hapus jadwal', size: 44, onPressed: _delete),
                  const SizedBox(width: 8),
                ],
                RoundIconButton(
                    icon: Icons.close_rounded, tooltip: 'Tutup', size: 44, onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _label('Judul Acara / Kuliah'),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              autofocus: !_isEdit,
              maxLength: EventStore.maxPanjangJudul,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: Kuliah Basis Data, Rapat Divisi', counterText: ''),
            ),
            const SizedBox(height: 14),
            _label('Jenis Acara'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in availableTypes)
                  ChoicePill(
                    label: t.label,
                    selected: _type == t,
                    selectedColor: t.ink,
                    selectedText: AppColors.white,
                    onTap: () => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _label(_repeatWeekly ? 'Pertemuan pertama & waktu' : 'Tanggal & Waktu'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    style: _pickerStyle,
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: Text(tanggalPendek(_date), style: AppText.body(13, weight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _pickTime(start: true),
                  style: _pickerStyle,
                  child: Text(_fmt(_startTime), style: AppText.body(13, weight: FontWeight.w800)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('–', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                OutlinedButton(
                  onPressed: () => _pickTime(start: false),
                  style: _pickerStyle,
                  child: Text(_fmt(_endTime), style: AppText.body(13, weight: FontWeight.w800)),
                ),
              ],
            ),
            if (jamSalah) ...[
              const SizedBox(height: 6),
              Text('Jam selesai harus setelah jam mulai.',
                  style: AppText.body(12, weight: FontWeight.w700, color: AppColors.expenseInk)),
            ],
            const SizedBox(height: 14),
            _label('Lokasi / Ruangan (opsional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _placeController,
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: Lab Komputer, Google Meet', counterText: ''),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _repeatWeekly,
              onChanged: (v) => setState(() => _repeatWeekly = v),
              title: Text('Ulangi setiap minggu', style: AppText.body(14, weight: FontWeight.w800)),
              subtitle: Text(
                _isEdit && widget.entry!.repeatWeekly
                    ? 'Perubahan berlaku untuk semua pertemuan'
                    : 'Setiap ${namaHari(_date)}',
                style: AppText.body(12, color: AppColors.muted),
              ),
              activeThumbColor: AppColors.yellow,
            ),
            if (_repeatWeekly) ...[
              _label('Ulangi sampai'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickRepeatUntil,
                  style: _pickerStyle,
                  icon: const Icon(Icons.event_repeat_rounded, size: 18),
                  label: Text(
                    '${tanggalPendek(_repeatUntil)} · ${selisihHari(_date, _repeatUntil) ~/ 7 + 1} pertemuan',
                    style: AppText.body(13, weight: FontWeight.w800),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            BoldButton(
              label: _saving ? 'Menyimpan…' : (_isEdit ? 'Simpan Perubahan' : 'Simpan Jadwal'),
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
