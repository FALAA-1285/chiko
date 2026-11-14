import 'package:flutter/foundation.dart';

import '../../../core/utils/clock.dart';
import '../../../core/utils/formatters.dart';
import 'task_model.dart';

export 'task_model.dart';

/// Penyimpanan tugas sementara (di memori) berisi data contoh.
/// Nanti isi kelas ini diganti query ke database drift (task_repository),
/// sedangkan layar tetap memakai method yang sama.
class TaskStore extends ChangeNotifier {
  TaskStore._();

  static final TaskStore instance = TaskStore._();

  int _nextId = 100;

  final List<Task> _tasks = [
    Task(
      id: 1,
      title: 'Laporan praktikum PCVK',
      category: TaskCategory.kuliah,
      groupName: 'PCVK',
      dueAt: DateTime(2026, 11, 17, 23, 59),
      priority: Priority.tinggi,
    ),
    Task(
      id: 2,
      title: 'Desain konten kampanye',
      category: TaskCategory.kerja,
      dueAt: DateTime(2026, 11, 18, 17, 0),
    ),
    Task(
      id: 3,
      title: 'Proyek akhir: ekstraksi fitur HOG',
      category: TaskCategory.kuliah,
      groupName: 'PCVK',
      dueAt: DateTime(2026, 11, 20, 23, 59),
      priority: Priority.tinggi,
    ),
    Task(
      id: 4,
      title: 'Bayar kos bulan Desember',
      category: TaskCategory.pribadi,
      dueAt: DateTime(2026, 11, 21, 12, 0),
      priority: Priority.rendah,
    ),
    Task(
      id: 5,
      title: 'Kuis Basis Data',
      category: TaskCategory.kuliah,
      dueAt: DateTime(2026, 11, 16, 23, 59),
      completedAt: DateTime(2026, 11, 15, 20, 0),
    ),
    Task(
      id: 6,
      title: 'Notulen rapat divisi',
      category: TaskCategory.kerja,
      dueAt: DateTime(2026, 11, 16, 12, 0),
      completedAt: DateTime(2026, 11, 14, 9, 0),
    ),
    Task(
      id: 7,
      title: 'Perpanjang SIM',
      category: TaskCategory.pribadi,
      dueAt: DateTime(2026, 11, 19, 15, 0),
      priority: Priority.rendah,
      completedAt: DateTime(2026, 11, 15, 11, 0),
    ),
  ];

  /// Tugas belum selesai, urut dari deadline terdekat.
  List<Task> get active => _tasks.where((t) => !t.done).toList()..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  /// Tugas selesai, yang terakhir diselesaikan di atas.
  List<Task> get completed => _tasks.where((t) => t.done).toList()..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  List<Task> completedOn(DateTime day) => completed.where((t) => samaHari(t.completedAt!, day)).toList();

  /// Tugas belum selesai yang deadline-nya jatuh di [day].
  List<Task> dueOn(DateTime day) => active.where((t) => samaHari(t.dueAt, day)).toList();

  /// Tugas dengan deadline dalam minggu yang sama dengan [now] (Senin–Minggu).
  List<Task> thisWeek(DateTime now) {
    final start = tanpaJam(now).subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return _tasks.where((t) => !t.dueAt.isBefore(start) && t.dueAt.isBefore(end)).toList();
  }

  void toggle(Task task) {
    task.completedAt = task.done ? null : sekarang();
    notifyListeners();
  }

  void add({
    required String title,
    required TaskCategory category,
    required DateTime dueAt,
    Priority priority = Priority.sedang,
    String? groupName,
  }) {
    _tasks.add(Task(
      id: _nextId++,
      title: title,
      category: category,
      dueAt: dueAt,
      priority: priority,
      groupName: groupName,
    ));
    notifyListeners();
  }
}
