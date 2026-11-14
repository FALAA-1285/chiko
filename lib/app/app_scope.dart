import 'package:flutter/widgets.dart';

import '../core/data/app_database.dart';
import '../features/calendar/data/event_store.dart';
import '../features/finance/data/finance_store.dart';
import '../features/settings/settings_store.dart';
import '../features/tasks/data/task_store.dart';

/// Semua store aplikasi, dibuat sekali di `main()` (atau di test) dan dibagikan lewat [AppScope].
class AppServices {
  AppServices._(this.db, this.tasks, this.events, this.finance, this.settings);

  final AppDatabase db;
  final TaskStore tasks;
  final EventStore events;
  final FinanceStore finance;
  final SettingsStore settings;

  /// Membuat store di atas [db] dan memuat semua data.
  static Future<AppServices> open(AppDatabase db) async {
    final tasks = TaskStore(db);
    final services = AppServices._(db, tasks, EventStore(db, tasks), FinanceStore(db), SettingsStore(db));
    await Future.wait([
      services.tasks.load(),
      services.events.load(),
      services.finance.load(),
      services.settings.load(),
    ]);
    return services;
  }

  Future<void> dispose() async {
    tasks.dispose();
    events.dispose();
    finance.dispose();
    settings.dispose();
    await db.close();
  }
}

/// Menyediakan [AppServices] ke seluruh pohon widget. Pakai `AppScope.of(context)`.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  /// Layanan tidak pernah berganti selama app hidup, jadi tidak mendaftarkan dependensi rebuild.
  /// Untuk update data, dengarkan store-nya (ListenableBuilder).
  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di atas widget ini.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
