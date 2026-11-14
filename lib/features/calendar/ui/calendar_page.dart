import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/mascot/chiko.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bold.dart';
import '../../tasks/data/task_store.dart';
import '../data/event_store.dart';
import 'widgets/event_tile.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  late DateTime _selected;
  bool _weekView = false;

  @override
  void initState() {
    super.initState();
    final now = sekarang();
    _month = DateTime(now.year, now.month);
    _selected = tanpaJam(now);
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selected = _month;
    });
  }

  /// 6 baris x 7 hari, Senin sebagai hari pertama.
  List<DateTime> _gridDays() {
    final first = DateTime(_month.year, _month.month, 1);
    final start = first.subtract(Duration(days: first.weekday - 1));
    return List.generate(42, (i) => DateTime(start.year, start.month, start.day + i));
  }

  void _openAddEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.ink, width: 2),
      ),
      builder: (context) => _AddEventSheet(initialDate: _selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = EventStore.instance;
    return Scaffold(
      floatingActionButton: AddFab(
        tooltip: 'Tambah jadwal',
        onPressed: () => _openAddEventSheet(context),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([events, TaskStore.instance]),
          builder: (context, _) {
            final now = sekarang();
            var days = _gridDays();
            if (_weekView) {
              final row = days.indexWhere((d) => samaHari(d, _selected)) ~/ 7;
              days = days.sublist(row * 7, row * 7 + 7);
            }
            final agenda = events.agendaOn(_selected);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Kalender', style: AppText.display(30))),
                    SegmentedPills(
                      labels: const ['Bulan', 'Minggu'],
                      selectedIndex: _weekView ? 1 : 0,
                      expand: false,
                      onChanged: (i) => setState(() => _weekView = i == 1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BoldCard(
                  radius: 24,
                  shadow: true,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          RoundIconButton(
                            icon: Icons.chevron_left_rounded,
                            tooltip: 'Bulan sebelumnya',
                            size: 40,
                            background: AppColors.cream,
                            onPressed: () => _changeMonth(-1),
                          ),
                          Expanded(
                            child: Text(
                              '${namaBulan(_month.month)} ${_month.year}',
                              textAlign: TextAlign.center,
                              style: AppText.display(20, weight: FontWeight.w600),
                            ),
                          ),
                          RoundIconButton(
                            icon: Icons.chevron_right_rounded,
                            tooltip: 'Bulan berikutnya',
                            size: 40,
                            background: AppColors.cream,
                            onPressed: () => _changeMonth(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          for (final h in hariPendekList)
                            Expanded(
                              child: Text(
                                h,
                                textAlign: TextAlign.center,
                                style: AppText.body(12, weight: FontWeight.w800, color: AppColors.muted),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      for (var r = 0; r < days.length ~/ 7; r++)
                        Row(
                          children: [
                            for (final d in days.sublist(r * 7, r * 7 + 7))
                              Expanded(
                                child: _DayCell(
                                  day: d,
                                  inMonth: d.month == _month.month,
                                  selected: samaHari(d, _selected),
                                  today: samaHari(d, now),
                                  dots: events.dotsOn(d),
                                  onTap: () => setState(() {
                                    _selected = d;
                                    if (d.month != _month.month) _month = DateTime(d.year, d.month);
                                  }),
                                ),
                              ),
                          ],
                        ),
                      const Divider(height: 18, thickness: 1.5, color: AppColors.line),
                      const Wrap(
                        spacing: 14,
                        alignment: WrapAlignment.center,
                        children: [
                          _Legend(color: AppColors.kuliahDot, label: 'Kuliah'),
                          _Legend(color: AppColors.kerjaDot, label: 'Kerja'),
                          _Legend(color: AppColors.danger, label: 'Deadline'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: tanggalPanjang(_selected),
                  trailing: agenda.isEmpty ? null : '${agenda.length} acara',
                ),
                const SizedBox(height: 10),
                if (agenda.isEmpty)
                  BoldCard(
                    padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
                    child: Row(
                      children: [
                        const Chiko(mood: ChikoMood.tidur, size: 96),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Hari ini kosong. Pas buat istirahat atau mencicil tugas.',
                            style: AppText.body(15, weight: FontWeight.w700, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final e in agenda) ...[
                    EventTile(event: e),
                    const SizedBox(height: 10),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.today,
    required this.dots,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool selected;
  final bool today;
  final List<Color> dots;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '${namaHari(day)} ${day.day} ${namaBulan(day.month)}'
        '${dots.isEmpty ? '' : ', ada acara'}';
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 50,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.yellow : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.ink : (today ? AppColors.line : Colors.transparent),
                    width: 2,
                  ),
                ),
                child: Text(
                  '${day.day}',
                  style: AppText.body(
                    15,
                    weight: selected || today ? FontWeight.w900 : FontWeight.w700,
                    color: inMonth ? AppColors.ink : const Color(0xFFB8AE99),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final c in dots)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppText.body(12, weight: FontWeight.w800, color: AppColors.inkSoft)),
      ],
    );
  }
}

class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  EventType _type = EventType.kuliah;
  late DateTime _date = widget.initialDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  bool _repeatWeekly = false;

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = sekarang();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Tanggal acara',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'Jam mulai',
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      helpText: 'Jam selesai',
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul jadwal tidak boleh kosong.')));
      return;
    }
    final start = DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute);
    final end = DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute);
    final place = _placeController.text.trim();

    EventStore.instance.add(
      ScheduleEntry(
        title: title,
        type: _type,
        start: start,
        end: end,
        place: place.isEmpty ? '' : place,
        repeatWeekly: _repeatWeekly,
        repeatUntil: _repeatWeekly ? DateTime(_date.year, 12, 31) : null,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Jadwal "$title" berhasil ditambahkan.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final availableTypes = [EventType.kuliah, EventType.kerja, EventType.pribadi];

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Tambah Jadwal Baru', style: AppText.display(22, weight: FontWeight.w600))),
                RoundIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Tutup',
                  size: 38,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Judul Acara / Kuliah', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: Kuliah Basis Data, Rapat Divisi'),
            ),
            const SizedBox(height: 14),
            Text('Jenis Acara', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
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
            Text('Tanggal & Waktu', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
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
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: Text(tanggalPendek(_date), style: AppText.body(13, weight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _pickStartTime,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.ink, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                    style: AppText.body(13, weight: FontWeight.w800),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('–', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                OutlinedButton(
                  onPressed: _pickEndTime,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.ink, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                    style: AppText.body(13, weight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Lokasi / Ruangan (opsional)', style: AppText.body(13, weight: FontWeight.w800, color: AppColors.muted)),
            const SizedBox(height: 6),
            TextField(
              controller: _placeController,
              textCapitalization: TextCapitalization.sentences,
              style: AppText.body(15),
              decoration: const InputDecoration(hintText: 'Misal: Lab Komputer, Google Meet'),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _repeatWeekly,
              onChanged: (v) => setState(() => _repeatWeekly = v),
              title: Text('Ulangi setiap minggu', style: AppText.body(14, weight: FontWeight.w800)),
              activeThumbColor: AppColors.yellow,
            ),
            const SizedBox(height: 16),
            BoldButton(label: 'Simpan Jadwal', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
