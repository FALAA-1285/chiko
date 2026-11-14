import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/data/app_database.dart';
import '../../../core/data/aturan_error.dart';
import '../../../core/utils/formatters.dart';
import '../../tasks/data/task_store.dart';
import 'event_model.dart';

export 'event_model.dart';

/// Jadwal di tabel `events`. Deadline tugas diambil dari [TaskStore] (tidak disalin ke sini).
class EventStore extends ChangeNotifier {
  EventStore(this._db, this._tasks);

  final AppDatabase _db;
  final TaskStore _tasks;

  static const maxPanjangJudul = 200;

  /// Lama pengulangan bawaan: satu semester (16 pertemuan mingguan).
  static const mingguPengulanganBawaan = 16;

  List<ScheduleEntry> _entries = const [];

  Future<void> load() async {
    _entries = await _db.select(_db.scheduleEntries).get();
    notifyListeners();
  }

  ScheduleEntry? byId(int id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Jadwal saja (tanpa deadline tugas) di [day], urut jam.
  List<CalendarEvent> scheduleOn(DateTime day) =>
      _entries.where((e) => e.occursOn(day)).map((e) => e.on(day)).toList()..sort((a, b) => a.start.compareTo(b.start));

  /// Jadwal + deadline tugas di [day].
  List<CalendarEvent> agendaOn(DateTime day) {
    final list = scheduleOn(day);
    for (final t in _tasks.dueOn(day)) {
      list.add(CalendarEvent(
        title: t.title,
        type: EventType.deadline,
        start: t.dueAt,
        place: 'Deadline · ${t.category.label}',
        taskId: t.id,
      ));
    }
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  /// Jenis acara di [day] untuk titik penanda sel kalender (maks. 3, tanpa duplikat).
  List<EventType> typesOn(DateTime day) {
    final types = <EventType>[];
    for (final e in agendaOn(day)) {
      if (!types.contains(e.type)) types.add(e.type);
    }
    return types.take(3).toList();
  }

  /// Aturan jadwal. Melempar [AturanError] bila tidak valid.
  static void validate({
    required String title,
    required EventType type,
    required DateTime start,
    required DateTime end,
    DateTime? repeatUntil,
  }) {
    final judul = title.trim();
    if (judul.isEmpty) throw const AturanError('Judul jadwal tidak boleh kosong.');
    if (judul.length > maxPanjangJudul) throw const AturanError('Judul jadwal terlalu panjang.');
    if (type == EventType.deadline) throw const AturanError('Deadline dibuat dari halaman Tugas.');
    if (!end.isAfter(start)) throw const AturanError('Jam selesai harus setelah jam mulai.');
    if (repeatUntil != null && tanpaJam(repeatUntil).isBefore(tanpaJam(start))) {
      throw const AturanError('Tanggal akhir pengulangan tidak boleh sebelum tanggal mulai.');
    }
  }

  /// Menambah jadwal, atau mengubah jadwal [editingId].
  Future<void> save({
    required String title,
    required EventType type,
    required DateTime start,
    required DateTime end,
    String place = '',
    bool repeatWeekly = false,
    DateTime? repeatUntil,
    int? editingId,
  }) async {
    validate(title: title, type: type, start: start, end: end, repeatUntil: repeatWeekly ? repeatUntil : null);
    final data = ScheduleEntriesCompanion(
      title: Value(title.trim()),
      type: Value(type),
      start: Value(start),
      end: Value(end),
      place: Value(place.trim()),
      repeatWeekly: Value(repeatWeekly),
      repeatUntil: Value(repeatWeekly ? repeatUntil : null),
    );
    if (editingId == null) {
      await _db.into(_db.scheduleEntries).insert(data);
    } else {
      await (_db.update(_db.scheduleEntries)..where((e) => e.id.equals(editingId))).write(data);
    }
    await load();
  }

  Future<void> remove(ScheduleEntry entry) async {
    await (_db.delete(_db.scheduleEntries)..where((e) => e.id.equals(entry.id))).go();
    await load();
  }

  Future<void> restore(ScheduleEntry entry) async {
    await _db.into(_db.scheduleEntries).insert(entry.toInsertable(), mode: InsertMode.insertOrIgnore);
    await load();
  }
}
