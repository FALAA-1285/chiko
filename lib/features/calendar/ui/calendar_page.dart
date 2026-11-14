import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../core/mascot/chiko.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/bold.dart';
import '../../tasks/data/task_store.dart';
import '../../tasks/ui/task_sheet.dart';
import '../../tasks/ui/task_style.dart';
import '../data/span_layout.dart';
import 'event_sheet.dart';
import 'event_style.dart';
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

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final events = app.events;
    final tasks = app.tasks;
    return Scaffold(
      floatingActionButton: AddFab(
        tooltip: 'Tambah jadwal',
        onPressed: () => bukaFormJadwal(context, tanggal: _selected),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([events, tasks]),
          builder: (context, _) {
            final now = sekarang();
            var days = _gridDays();
            if (_weekView) {
              final row = days.indexWhere((d) => samaHari(d, _selected)) ~/ 7;
              days = days.sublist(row * 7, row * 7 + 7);
            }
            final agenda = events.agendaOn(_selected);
            final berjalan = tasks.spanningOn(_selected);

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
                        // Sel tanggal berukuran tetap: skala teks dibatasi supaya angka tidak terpotong.
                        MediaQuery.withClampedTextScaling(
                          maxScaleFactor: 1.3,
                          child: _WeekRow(
                            days: days.sublist(r * 7, r * 7 + 7),
                            bars: layoutWeek(days[r * 7], tasks.spansBetween(days[r * 7], days[r * 7 + 6])),
                            month: _month,
                            selected: _selected,
                            now: now,
                            dotsOf: (d) => [for (final t in events.typesOn(d)) t.dot],
                            onSelect: (d) => setState(() {
                              _selected = d;
                              if (d.month != _month.month) _month = DateTime(d.year, d.month);
                            }),
                          ),
                        ),
                      const Divider(height: 18, thickness: 1.5, color: AppColors.line),
                      const Wrap(
                        spacing: 14,
                        runSpacing: 4,
                        alignment: WrapAlignment.center,
                        children: [
                          _Legend(color: AppColors.kuliahDot, label: 'Kuliah'),
                          _Legend(color: AppColors.kerjaDot, label: 'Kerja'),
                          _Legend(color: AppColors.pribadiDot, label: 'Pribadi'),
                          _Legend(color: AppColors.danger, label: 'Deadline'),
                          _Legend(color: AppColors.ink, label: 'Blok = rentang proyek', bar: true),
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
                if (berjalan.isNotEmpty) ...[
                  const _SubLabel('Proyek berjalan'),
                  const SizedBox(height: 8),
                  for (final t in berjalan) ...[
                    _SpanTile(task: t, day: _selected, onTap: () => bukaFormTugas(context, task: t)),
                    const SizedBox(height: 10),
                  ],
                  if (agenda.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    const _SubLabel('Jadwal & deadline'),
                    const SizedBox(height: 8),
                  ],
                ],
                if (agenda.isEmpty && berjalan.isEmpty)
                  BoldCard(
                    padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
                    child: Row(
                      children: [
                        const Chiko(mood: ChikoMood.tidur, size: 96),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            samaHari(_selected, now)
                                ? 'Hari ini kosong. Pas buat istirahat atau mencicil tugas.'
                                : 'Tidak ada acara di tanggal ini.',
                            style: AppText.body(15, weight: FontWeight.w700, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final e in agenda) ...[
                    EventTile(
                      event: e,
                      onTap: () {
                        final entry = e.entryId == null ? null : events.byId(e.entryId!);
                        final task = e.taskId == null ? null : tasks.byId(e.taskId!);
                        if (entry != null) bukaFormJadwal(context, entry: entry);
                        if (task != null) bukaFormTugas(context, task: task);
                      },
                    ),
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
    this.height = 50,
    this.extraLabel = '',
  });

  final double height;

  /// Tambahan label pembaca layar, mis. proyek yang berjalan di hari ini.
  final String extraLabel;
  final DateTime day;
  final bool inMonth;
  final bool selected;
  final bool today;
  final List<Color> dots;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '${namaHari(day)} ${day.day} ${namaBulan(day.month)}'
        '${dots.isEmpty ? '' : ', ada acara'}'
        '${extraLabel.isEmpty ? '' : ', berjalan: $extraLabel'}';
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: height,
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
                    color: inMonth ? AppColors.ink : const Color(0xFF8C8370),
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
  const _Legend({required this.color, required this.label, this.bar = false});

  final Color color;
  final String label;
  final bool bar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        bar
            ? Container(
                width: 18,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.yellowSoft,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: color, width: 1.5),
                ),
              )
            : Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppText.body(12, weight: FontWeight.w800, color: AppColors.inkSoft)),
      ],
    );
  }
}

/// Satu baris minggu: 7 sel tanggal + blok proyek berentang di bawah angka tanggal.
class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.days,
    required this.bars,
    required this.month,
    required this.selected,
    required this.now,
    required this.dotsOf,
    required this.onSelect,
  });

  final List<DateTime> days;
  final List<SpanBar> bars;
  final DateTime month;
  final DateTime selected;
  final DateTime now;
  final List<Color> Function(DateTime) dotsOf;
  final ValueChanged<DateTime> onSelect;

  static const _maxLanes = 3;
  static const _barTop = 50.0;
  static const _barHeight = 15.0;
  static const _barGap = 2.0;

  @override
  Widget build(BuildContext context) {
    final visible = bars.where((b) => b.lane < _maxLanes).toList();
    final hidden = bars.where((b) => b.lane >= _maxLanes).toList();
    final lanes = visible.isEmpty ? 0 : visible.map((b) => b.lane).reduce((a, b) => a > b ? a : b) + 1;
    final overflowRow = hidden.isNotEmpty ? 1 : 0;
    final height = _barTop + (lanes + overflowRow) * (_barHeight + _barGap) + (lanes > 0 ? 4 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW = constraints.maxWidth / 7;
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: _DayCell(
                        day: days[c],
                        height: height,
                        inMonth: days[c].month == month.month,
                        selected: samaHari(days[c], selected),
                        today: samaHari(days[c], now),
                        dots: dotsOf(days[c]),
                        extraLabel: bars.where((b) => b.covers(c)).map((b) => b.task.title).join(', '),
                        onTap: () => onSelect(days[c]),
                      ),
                    ),
                ],
              ),
              // Blok tidak menangkap ketukan, jadi ketukan tetap memilih tanggal di bawahnya.
              for (final b in visible)
                Positioned(
                  left: b.startCol * cellW + (b.continuesLeft ? 0 : 2),
                  width: (b.endCol - b.startCol + 1) * cellW - (b.continuesLeft ? 0 : 2) - (b.continuesRight ? 0 : 2),
                  top: _barTop + b.lane * (_barHeight + _barGap),
                  height: _barHeight,
                  child: IgnorePointer(child: _SpanBarView(bar: b, now: now)),
                ),
              for (var c = 0; c < 7; c++)
                if (hidden.any((b) => b.covers(c)))
                  Positioned(
                    left: c * cellW,
                    width: cellW,
                    top: _barTop + lanes * (_barHeight + _barGap),
                    height: _barHeight,
                    child: IgnorePointer(
                      child: Center(
                        child: Text(
                          '+${hidden.where((b) => b.covers(c)).length}',
                          style: AppText.body(10, weight: FontWeight.w900, color: AppColors.muted),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _SpanBarView extends StatelessWidget {
  const _SpanBarView({required this.bar, required this.now});

  final SpanBar bar;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = bar.task;
    final terlambat = t.isOverdue(now);
    final border = terlambat ? AppColors.danger : t.category.dot;
    final side = BorderSide(color: border, width: 1.5);
    return Opacity(
      opacity: t.done ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: terlambat ? AppColors.expenseSoft : t.category.soft,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(bar.continuesLeft ? 0 : 5),
            right: Radius.circular(bar.continuesRight ? 0 : 5),
          ),
          border: Border(
            top: side,
            bottom: side,
            left: bar.continuesLeft ? BorderSide.none : BorderSide(color: border, width: 3),
            right: bar.continuesRight ? BorderSide.none : side,
          ),
        ),
        child: Text(
          bar.continuesLeft ? '... ${t.title}' : t.title,
          maxLines: 1,
          overflow: TextOverflow.clip,
          softWrap: false,
          style: AppText.body(10, weight: FontWeight.w800, color: terlambat ? AppColors.expenseInk : t.category.ink)
              .copyWith(
            height: 1.1,
            decoration: t.done ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}

/// Kartu proyek yang sedang berjalan di tanggal terpilih, dengan progres waktunya.
class _SpanTile extends StatelessWidget {
  const _SpanTile({required this.task, required this.day, required this.onTap});

  final Task task;
  final DateTime day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = task.durasiHari;
    final ke = (selisihHari(task.startAt!, day) + 1).clamp(1, total);
    final sisa = selisihHari(day, task.dueAt);
    final status = task.done
        ? 'Sudah selesai'
        : sisa == 0
            ? 'Hari terakhir · deadline ${jam(task.dueAt)}'
            : 'Hari ke-$ke dari $total · sisa $sisa hari';
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: BoldCard(
          color: task.category.soft,
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TagChip(
                      label: task.category.label,
                      background: AppColors.white,
                      foreground: task.category.ink,
                      outlined: true),
                  const SizedBox(width: 8),
                  Icon(Icons.date_range_rounded, size: 15, color: task.category.ink),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rentangTanggal(task.startAt!, task.dueAt),
                      style: AppText.body(13, weight: FontWeight.w800, color: task.category.ink),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                task.title,
                style: AppText.body(16, weight: FontWeight.w800, height: 1.3).copyWith(
                  decoration: task.done ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 8),
              BoldProgressBar(value: task.done ? 1 : ke / total, fill: task.category.dot),
              const SizedBox(height: 6),
              Text(status, style: AppText.body(12, weight: FontWeight.w700, color: AppColors.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppText.body(13, weight: FontWeight.w900, color: AppColors.muted).copyWith(letterSpacing: 0.8),
    );
  }
}
