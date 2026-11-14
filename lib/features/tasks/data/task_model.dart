import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';

enum TaskCategory { kuliah, kerja, pribadi }

extension TaskCategoryStyle on TaskCategory {
  String get label => switch (this) {
        TaskCategory.kuliah => 'Kuliah',
        TaskCategory.kerja => 'Kerja',
        TaskCategory.pribadi => 'Pribadi',
      };

  Color get soft => switch (this) {
        TaskCategory.kuliah => AppColors.kuliahSoft,
        TaskCategory.kerja => AppColors.kerjaSoft,
        TaskCategory.pribadi => AppColors.pribadiSoft,
      };

  Color get ink => switch (this) {
        TaskCategory.kuliah => AppColors.kuliahInk,
        TaskCategory.kerja => AppColors.kerjaInk,
        TaskCategory.pribadi => AppColors.pribadiInk,
      };

  Color get dot => switch (this) {
        TaskCategory.kuliah => AppColors.kuliahDot,
        TaskCategory.kerja => AppColors.kerjaDot,
        TaskCategory.pribadi => AppColors.pribadiDot,
      };
}

enum Priority { rendah, sedang, tinggi }

extension PriorityStyle on Priority {
  String get label => switch (this) {
        Priority.rendah => 'Rendah',
        Priority.sedang => 'Sedang',
        Priority.tinggi => 'Tinggi',
      };

  Color get color => switch (this) {
        Priority.rendah => AppColors.muted,
        Priority.sedang => const Color(0xFF9A5B00),
        Priority.tinggi => AppColors.expenseInk,
      };
}

/// Sesuai tabel `tasks` di dokumen rancangan.
class Task {
  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.dueAt,
    this.groupName,
    this.priority = Priority.sedang,
    this.note,
    this.completedAt,
  });

  final int id;
  final String title;
  final TaskCategory category;
  final DateTime dueAt;

  /// Nama mata kuliah atau proyek, mis. "PCVK".
  final String? groupName;
  final Priority priority;
  final String? note;
  DateTime? completedAt;

  bool get done => completedAt != null;

  /// Mepet = deadline-nya hari ini, besok, atau sudah lewat.
  bool isUrgent(DateTime now) => !done && tanpaJam(dueAt).difference(tanpaJam(now)).inDays <= 1;
}
