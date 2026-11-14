import '../../../core/utils/formatters.dart';

/// Model jadwal — Dart murni. Warna ada di `ui/event_style.dart`.
enum EventType {
  kuliah('Kuliah'),
  kerja('Kerja'),
  pribadi('Pribadi'),
  deadline('Deadline tugas');

  const EventType(this.label);
  final String label;
}

/// Satu kemunculan acara di tanggal tertentu (sudah "dibuka" dari pola berulang).
class CalendarEvent {
  const CalendarEvent({
    required this.title,
    required this.type,
    required this.start,
    this.end,
    this.place = '',
    this.entryId,
    this.taskId,
  });

  final String title;
  final EventType type;
  final DateTime start;
  final DateTime? end;
  final String place;

  /// Sumber acara: jadwal ([entryId]) atau deadline tugas ([taskId]).
  final int? entryId;
  final int? taskId;
}

/// Sesuai tabel `events`: disimpan sekali, bisa berulang tiap minggu sampai [repeatUntil].
class ScheduleEntry {
  const ScheduleEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.start,
    required this.end,
    this.place = '',
    this.repeatWeekly = false,
    this.repeatUntil,
  });

  final int id;
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
    if (repeatUntil != null && d.isAfter(tanpaJam(repeatUntil!))) return false;
    return d.weekday == first.weekday;
  }

  CalendarEvent on(DateTime day) {
    DateTime at(DateTime t) => DateTime(day.year, day.month, day.day, t.hour, t.minute);
    return CalendarEvent(title: title, type: type, start: at(start), end: at(end), place: place, entryId: id);
  }

  @override
  bool operator ==(Object other) => other is ScheduleEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
