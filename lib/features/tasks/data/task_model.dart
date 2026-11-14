import '../../../core/utils/formatters.dart';

/// Model tugas — Dart murni (tanpa warna/ikon). Gaya tampilan ada di `ui/task_style.dart`.
enum TaskCategory {
  kuliah('Kuliah'),
  kerja('Kerja'),
  pribadi('Pribadi');

  const TaskCategory(this.label);
  final String label;
}

enum Priority {
  rendah('Rendah'),
  sedang('Sedang'),
  tinggi('Tinggi');

  const Priority(this.label);
  final String label;
}

/// Sesuai tabel `tasks`. Objek tidak bisa diubah; pakai [copyWith].
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.category,
    required this.dueAt,
    this.startAt,
    this.groupName,
    this.priority = Priority.sedang,
    this.note,
    this.completedAt,
  });

  final int id;
  final String title;
  final TaskCategory category;
  final DateTime dueAt;

  /// Tanggal mulai (opsional). Bila diisi, tugas/proyek tampil sebagai blok
  /// memanjang di kalender dari [startAt] sampai [dueAt].
  final DateTime? startAt;

  /// Nama mata kuliah atau proyek, mis. "PCVK".
  final String? groupName;
  final Priority priority;
  final String? note;
  final DateTime? completedAt;

  bool get done => completedAt != null;

  /// Punya rentang waktu (mulai–selesai)?
  bool get hasSpan => startAt != null;

  /// Lama rentang dalam hari kalender (inklusif). 1 bila tanpa tanggal mulai.
  int get durasiHari => hasSpan ? selisihHari(startAt!, dueAt) + 1 : 1;

  /// Apakah rentang tugas ini mencakup [day]?
  bool spans(DateTime day) => hasSpan && selisihHari(startAt!, day) >= 0 && selisihHari(day, dueAt) >= 0;

  /// Terlambat = belum selesai dan jam deadline-nya sudah lewat.
  bool isOverdue(DateTime now) => !done && dueAt.isBefore(now);

  /// Mepet = deadline-nya hari ini, besok, atau sudah lewat.
  bool isUrgent(DateTime now) => !done && selisihHari(now, dueAt) <= 1;

  /// Untuk field nullable, kirim fungsi agar bisa diisi `null`: `copyWith(startAt: () => null)`.
  Task copyWith({
    String? title,
    TaskCategory? category,
    DateTime? dueAt,
    DateTime? Function()? startAt,
    String? Function()? groupName,
    Priority? priority,
    String? Function()? note,
    DateTime? Function()? completedAt,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        dueAt: dueAt ?? this.dueAt,
        startAt: startAt != null ? startAt() : this.startAt,
        groupName: groupName != null ? groupName() : this.groupName,
        priority: priority ?? this.priority,
        note: note != null ? note() : this.note,
        completedAt: completedAt != null ? completedAt() : this.completedAt,
      );

  @override
  bool operator ==(Object other) => other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
