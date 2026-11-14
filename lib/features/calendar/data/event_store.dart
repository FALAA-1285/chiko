import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../tasks/data/task_store.dart';

enum EventType { kuliah, kerja, pribadi, deadline }

extension EventTypeStyle on EventType {
  String get label => switch (this) {
        EventType.kuliah => 'Kuliah',
        EventType.kerja => 'Kerja',
        EventType.pribadi => 'Pribadi',
        EventType.deadline => 'Deadline tugas',
      };

  Color get soft => switch (this) {
        EventType.kuliah => AppColors.kuliahSoft,
        EventType.kerja => AppColors.kerjaSoft,
        EventType.pribadi => AppColors.pribadiSoft,
        EventType.deadline => AppColors.expenseSoft,
      };

  Color get ink => switch (this) {
        EventType.kuliah => AppColors.kuliahInk,
        EventType.kerja => AppColors.kerjaInk,
        EventType.pribadi => AppColors.pribadiInk,
        EventType.deadline => AppColors.expenseInk,
      };

  Color get dot => switch (this) {
        EventType.kuliah => AppColors.kuliahDot,
        EventType.kerja => AppColors.kerjaDot,
        EventType.pribadi => AppColors.pribadiDot,
        EventType.deadline => AppColors.danger,
      };
}

/// Satu kemunculan acara di tanggal tertentu (sudah "dibuka" dari pola berulang).
class CalendarEvent {
  const CalendarEvent({required this.title, required this.type, required this.start, this.end, this.place = ''});

  final String title;
  final EventType type;
  final DateTime start;
  final DateTime? end;
  final String place;
}

/// Sesuai tabel `events`: disimpan sekali, berulang tiap minggu sampai [repeatUntil].
class ScheduleEntry {
  const ScheduleEntry({
    required this.title,
    required this.type,
    required this.start,
    required this.end,
    this.place = '',
    this.repeatWeekly = false,
    this.repeatUntil,
  });

  final String title;
  final EventType type;
  final DateTime start;
  final DateTime end;
  final String place;
  final bool repeatWeekly;
  final DateTime? repeatUntil;

  /// Apakah acara ini muncul di [day]?
  bool occursOn(DateTime day) {
    final d = tanpaJam(day);
    final first = tanpaJam(start);
    if (d.isBefore(first)) return false;
    if (!repeatWeekly) return samaHari(first, d);
    if (repeatUntil != null && d.isAfter(repeatUntil!)) return false;
    return d.weekday == first.weekday;
  }

  CalendarEvent on(DateTime day) {
    DateTime at(DateTime t) => DateTime(day.year, day.month, day.day, t.hour, t.minute);
    return CalendarEvent(title: title, type: type, start: at(start), end: at(end), place: place);
  }
}

/// Jadwal contoh di memori. Deadline tugas diambil langsung dari [TaskStore],
/// tidak disalin ke sini.
class EventStore extends ChangeNotifier {
  EventStore._();

  static final EventStore instance = EventStore._();

  final List<ScheduleEntry> _entries = [
    ScheduleEntry(
      title: 'Pengolahan Citra dan Visi Komputer',
      type: EventType.kuliah,
      start: DateTime(2026, 9, 7, 7, 0),
      end: DateTime(2026, 9, 7, 9, 30),
      place: 'Lab komputer · berulang tiap Senin',
      repeatWeekly: true,
      repeatUntil: DateTime(2026, 12, 31),
    ),
    for (final day in [2, 16, 30])
      ScheduleEntry(
        title: 'Rapat divisi',
        type: EventType.kerja,
        start: DateTime(2026, 11, day, 13, 0),
        end: DateTime(2026, 11, day, 15, 0),
        place: 'Online · Google Meet',
      ),
  ];

  /// Jadwal saja (tanpa deadline tugas) di [day], urut jam.
  List<CalendarEvent> scheduleOn(DateTime day) =>
      _entries.where((e) => e.occursOn(day)).map((e) => e.on(day)).toList()..sort((a, b) => a.start.compareTo(b.start));

  /// Jadwal + deadline tugas di [day].
  List<CalendarEvent> agendaOn(DateTime day) {
    final list = scheduleOn(day);
    for (final t in TaskStore.instance.dueOn(day)) {
      list.add(CalendarEvent(title: t.title, type: EventType.deadline, start: t.dueAt, place: 'Deadline · ${t.category.label}'));
    }
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  /// Warna titik penanda untuk sel kalender (maks. 3, tanpa duplikat).
  List<Color> dotsOn(DateTime day) {
    final colors = <Color>[];
    for (final e in agendaOn(day)) {
      if (!colors.contains(e.type.dot)) colors.add(e.type.dot);
    }
    return colors.take(3).toList();
  }

  void add(ScheduleEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }
}
