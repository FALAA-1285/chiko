import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../data/task_model.dart';

/// Warna kategori & prioritas tugas (lapisan tampilan).
extension TaskCategoryStyle on TaskCategory {
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

extension PriorityStyle on Priority {
  Color get color => switch (this) {
        Priority.rendah => AppColors.muted,
        Priority.sedang => const Color(0xFF9A5B00),
        Priority.tinggi => AppColors.expenseInk,
      };
}
