import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/data/app_database.dart';
import '../../../core/data/aturan_error.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import 'task_model.dart';

export 'task_model.dart';

/// Tugas: disimpan di tabel `tasks`, disalin ke memori supaya layar bisa membaca
/// secara sinkron. Setiap perubahan ditulis ke database lalu cache dimuat ulang.
class TaskStore extends ChangeNotifier {
  TaskStore(this._db);

  final AppDatabase _db;

  /// Batas panjang judul tugas (sama dengan kolom database).
  static const maxPanjangJudul = 200;

  List<Task> _tasks = const [];
  List<Task>? _active;
  List<Task>? _completed;

  Future<void> load() async {
    _tasks = await _db.select(_db.tasks).get();
    _active = null;
    _completed = null;
    notifyListeners();
  }

  List<Task> get all => List.unmodifiable(_tasks);

  Task? byId(int id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Tugas belum selesai, urut dari deadline terdekat.
  List<Task> get active =>
      _active ??= List.unmodifiable(_tasks.where((t) => !t.done).toList()..sort((a, b) => a.dueAt.compareTo(b.dueAt)));

  /// Tugas selesai, yang terakhir diselesaikan di atas.
  List<Task> get completed => _completed ??=
      List.unmodifiable(_tasks.where((t) => t.done).toList()..sort((a, b) => b.completedAt!.compareTo(a.completedAt!)));

  List<Task> completedOn(DateTime day) => completed.where((t) => samaHari(t.completedAt!, day)).toList();

  /// Tugas belum selesai yang deadline-nya jatuh di [day].
  List<Task> dueOn(DateTime day) => active.where((t) => samaHari(t.dueAt, day)).toList();

  /// Tugas dengan deadline dalam minggu yang sama dengan [now] (Senin–Minggu).
  List<Task> thisWeek(DateTime now) {
    final start = awalMinggu(now);
    final end = DateTime(start.year, start.month, start.day + 7);
    return _tasks.where((t) => !t.dueAt.isBefore(start) && t.dueAt.isBefore(end)).toList();
  }

  /// Tugas berentang (punya tanggal mulai) yang beririsan dengan [from]..[to] (per hari, inklusif).
  /// Urut dari yang mulai lebih awal, lalu yang lebih panjang.
  List<Task> spansBetween(DateTime from, DateTime to) =>
      _tasks.where((t) => t.hasSpan && selisihHari(t.startAt!, to) >= 0 && selisihHari(from, t.dueAt) >= 0).toList()
        ..sort((a, b) {
          final c = a.startAt!.compareTo(b.startAt!);
          return c != 0 ? c : b.durasiHari.compareTo(a.durasiHari);
        });

  /// Tugas berentang yang sedang berjalan di [day].
  List<Task> spanningOn(DateTime day) => spansBetween(day, day);

  /// Aturan tugas. Melempar [AturanError] bila tidak valid.
  /// [requireFutureDeadline]: untuk tugas baru, deadline harus setelah sekarang.
  static void validate({
    required String title,
    required DateTime dueAt,
    DateTime? startAt,
    bool requireFutureDeadline = false,
  }) {
    final judul = title.trim();
    if (judul.isEmpty) throw const AturanError('Judul tugas tidak boleh kosong.');
    if (judul.length > maxPanjangJudul) throw const AturanError('Judul tugas terlalu panjang.');
    if (startAt != null && selisihHari(startAt, dueAt) < 0) {
      throw const AturanError('Tanggal mulai tidak boleh setelah deadline.');
    }
    if (requireFutureDeadline && !dueAt.isAfter(sekarang())) {
      throw const AturanError('Deadline harus setelah waktu sekarang.');
    }
  }

  Future<Task> add({
    required String title,
    required TaskCategory category,
    required DateTime dueAt,
    DateTime? startAt,
    Priority priority = Priority.sedang,
    String? groupName,
    bool requireFutureDeadline = true,
  }) async {
    validate(title: title, dueAt: dueAt, startAt: startAt, requireFutureDeadline: requireFutureDeadline);
    final group = groupName?.trim();
    final id = await _db.into(_db.tasks).insert(TasksCompanion.insert(
          title: title.trim(),
          category: category,
          priority: priority,
          dueAt: dueAt,
          startAt: Value(startAt == null ? null : tanpaJam(startAt)),
          groupName: Value(group == null || group.isEmpty ? null : group),
        ));
    await load();
    return byId(id)!;
  }

  /// Menyimpan perubahan tugas yang sudah ada.
  Future<void> update(Task task) async {
    validate(title: task.title, dueAt: task.dueAt, startAt: task.startAt);
    final group = task.groupName?.trim();
    final rapi = task.copyWith(
      title: task.title.trim(),
      startAt: () => task.startAt == null ? null : tanpaJam(task.startAt!),
      groupName: () => group == null || group.isEmpty ? null : group,
    );
    await _db.update(_db.tasks).replace(rapi.toInsertable());
    await load();
  }

  Future<void> toggle(Task task) async {
    final current = byId(task.id) ?? task;
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id)))
        .write(TasksCompanion(completedAt: Value(current.done ? null : sekarang())));
    await load();
  }

  Future<void> remove(Task task) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(task.id))).go();
    await load();
  }

  /// Mengembalikan tugas yang baru dihapus (dengan id yang sama).
  Future<void> restore(Task task) async {
    await _db.into(_db.tasks).insert(task.toInsertable(), mode: InsertMode.insertOrIgnore);
    await load();
  }
}
