import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/calendar/data/event_model.dart';
import '../../features/finance/data/finance_defaults.dart';
import '../../features/finance/data/finance_model.dart';
import '../../features/tasks/data/task_model.dart';

part 'app_database.g.dart';

/// Tabel `tasks` → [Task].
@UseRowClass(Task, generateInsertable: true)
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get category => textEnum<TaskCategory>()();
  TextColumn get groupName => text().nullable()();
  TextColumn get priority => textEnum<Priority>()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// Tabel `events` → [ScheduleEntry].
@UseRowClass(ScheduleEntry, generateInsertable: true)
class ScheduleEntries extends Table {
  @override
  String get tableName => 'events';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get type => textEnum<EventType>()();
  DateTimeColumn get start => dateTime().named('start_at')();
  DateTimeColumn get end => dateTime().named('end_at')();
  TextColumn get place => text().withDefault(const Constant(''))();
  BoolColumn get repeatWeekly => boolean().withDefault(const Constant(false))();
  DateTimeColumn get repeatUntil => dateTime().nullable()();
}

/// Tabel `accounts` → [Account].
@UseRowClass(Account, generateInsertable: true)
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get type => textEnum<AccountType>()();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  IntColumn get colorValue => integer()();
}

/// Tabel `categories` → [TxnCategory].
@UseRowClass(TxnCategory, generateInsertable: true)
class TxnCategories extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get kind => textEnum<TxnKind>()();
  TextColumn get iconKey => text()();
  IntColumn get colorValue => integer()();
  IntColumn get softValue => integer()();
}

/// Tabel `transactions` → [Txn]. Akun & kategori yang masih dipakai tidak bisa dihapus.
@UseRowClass(Txn, generateInsertable: true)
class Txns extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => textEnum<TxnKind>()();
  // ignore: recursive_getters
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();
  @ReferenceName('txnsFrom')
  IntColumn get accountId => integer().references(Accounts, #id, onDelete: KeyAction.restrict)();
  @ReferenceName('txnsTo')
  IntColumn get toAccountId => integer().nullable().references(Accounts, #id, onDelete: KeyAction.restrict)();
  IntColumn get categoryId => integer().nullable().references(TxnCategories, #id, onDelete: KeyAction.restrict)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
}

/// Pengaturan sederhana (kunci → nilai), mis. nama pengguna.
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [Tasks, ScheduleEntries, Accounts, TxnCategories, Txns, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Database di penyimpanan perangkat (file `chiko.sqlite` di folder dokumen aplikasi).
  factory AppDatabase.openDefault() => AppDatabase(driftDatabase(name: 'chiko'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await isiDataBawaan();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        // Tambahkan langkah `onUpgrade` di sini saat schemaVersion dinaikkan.
      );

  /// Kategori dan akun bawaan untuk pengguna baru.
  Future<void> isiDataBawaan() async {
    await batch((b) {
      b.insertAll(txnCategories, [
        for (final (nama, jenis, ikon, warna) in kategoriBawaan)
          TxnCategoriesCompanion.insert(
            name: nama,
            kind: jenis,
            iconKey: ikon,
            colorValue: paletKategori[warna].$1,
            softValue: paletKategori[warna].$2,
          ),
      ]);
      final (nama, jenis, saldo) = akunBawaan;
      b.insert(
        accounts,
        AccountsCompanion.insert(name: nama, type: jenis, initialBalance: Value(saldo), colorValue: paletAkun[2]),
      );
    });
  }
}
