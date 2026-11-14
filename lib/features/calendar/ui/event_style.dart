import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../data/event_model.dart';

extension EventTypeStyle on EventType {
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
