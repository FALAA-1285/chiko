import 'package:chiko/app/app_scope.dart';
import 'package:chiko/core/data/app_database.dart';
import 'package:chiko/core/utils/clock.dart';
import 'package:chiko/features/calendar/data/event_store.dart';
import 'package:chiko/features/finance/data/finance_store.dart';
import 'package:chiko/features/tasks/data/task_store.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';

/// "Sekarang" di semua test: Senin, 16 November 2026, 10.00.
final jamTest = DateTime(2026, 11, 16, 10);

/// Layanan app di atas database SQLite di memori (bersih untuk setiap test).
Future<AppServices> bukaLayananTest({bool dataContoh = true, bool onboardingSelesai = true}) async {
  // Setiap test membuat database baru; peringatan "banyak database" dari drift tidak relevan.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  aturJam(() => jamTest);
  final services = await AppServices.open(AppDatabase(NativeDatabase.memory()));
  if (dataContoh) await isiDataContoh(services);
  if (onboardingSelesai) await services.settings.selesaikanOnboarding();
  return services;
}

/// Data contoh (seperti desain): 3 akun, 15 transaksi November, 8 tugas, jadwal kuliah & rapat.
Future<void> isiDataContoh(AppServices s) async {
  final f = s.finance;
  final dompet = f.accounts.single; // akun bawaan
  await f.saveAccount(
      name: 'Dompet',
      type: AccountType.cash,
      initialBalance: 50000,
      colorValue: dompet.colorValue,
      editingId: dompet.id);
  await f.saveAccount(name: 'BTN', type: AccountType.bank, initialBalance: 300000, colorValue: 0xFFE4EDFF);
  await f.saveAccount(name: 'BRI', type: AccountType.bank, initialBalance: 120000, colorValue: 0xFFFFF0B3);
  int akun(String nama) => f.accounts.firstWhere((a) => a.name == nama).id;
  int kat(String nama, TxnKind kind) => f.categories.firstWhere((c) => c.name == nama && c.kind == kind).id;

  Future<void> txn(TxnKind kind, int amount, String from, DateTime date, {String? to, String? cat, String note = ''}) =>
      f.saveTxn(
        kind: kind,
        amount: amount,
        accountId: akun(from),
        toAccountId: to == null ? null : akun(to),
        categoryId: cat == null ? null : kat(cat, kind),
        note: note,
        date: date,
        now: jamTest,
      );

  // Pemasukan & transfer dulu supaya validasi saldo tidak menolak pengeluaran.
  await txn(TxnKind.income, 1500000, 'BTN', DateTime(2026, 11, 12, 8), cat: 'Uang saku', note: 'Uang saku');
  await txn(TxnKind.income, 500000, 'BRI', DateTime(2026, 11, 12, 9), cat: 'Honor kerja', note: 'Honor kerja');
  await txn(TxnKind.transfer, 150000, 'BTN', DateTime(2026, 11, 2, 9), to: 'Dompet', note: 'Tarik tunai');
  await txn(TxnKind.transfer, 100000, 'BRI', DateTime(2026, 11, 15, 11), to: 'Dompet', note: 'Tarik tunai');
  await txn(TxnKind.expense, 150000, 'BTN', DateTime(2026, 11, 3, 18), cat: 'Makan', note: 'Belanja makanan mingguan');
  await txn(TxnKind.expense, 45000, 'Dompet', DateTime(2026, 11, 4, 14),
      cat: 'Kuliah', note: 'Print dan jilid laporan');
  await txn(TxnKind.expense, 130000, 'BTN', DateTime(2026, 11, 5, 10), cat: 'Transport', note: 'Servis motor');
  await txn(TxnKind.expense, 80000, 'BRI', DateTime(2026, 11, 6, 8), cat: 'Lainnya', note: 'Pulsa dan kuota');
  await txn(TxnKind.expense, 85000, 'BRI', DateTime(2026, 11, 7, 19), cat: 'Makan', note: 'Makan bareng teman');
  await txn(TxnKind.expense, 55000, 'BRI', DateTime(2026, 11, 8, 20), cat: 'Hiburan', note: 'Nonton bioskop');
  await txn(TxnKind.expense, 75000, 'BTN', DateTime(2026, 11, 9, 13), cat: 'Kuliah', note: 'Buku referensi');
  await txn(TxnKind.expense, 60000, 'Dompet', DateTime(2026, 11, 10, 16), cat: 'Makan', note: 'Jajan dan kopi');
  await txn(TxnKind.expense, 30000, 'BRI', DateTime(2026, 11, 15, 12), cat: 'Hiburan', note: 'Langganan musik');
  await txn(TxnKind.expense, 20000, 'Dompet', DateTime(2026, 11, 16, 7, 30), cat: 'Transport', note: 'Bensin motor');
  await txn(TxnKind.expense, 25000, 'Dompet', DateTime(2026, 11, 16, 9, 45), cat: 'Makan', note: 'Makan siang');

  final t = s.tasks;
  Future<Task> tugas(String title, TaskCategory c, DateTime due,
          {DateTime? start, Priority p = Priority.sedang, String? group}) =>
      t.add(
          title: title,
          category: c,
          dueAt: due,
          startAt: start,
          priority: p,
          groupName: group,
          requireFutureDeadline: false);
  Future<void> selesai(Task task, DateTime kapan) => t.update(task.copyWith(completedAt: () => kapan));

  await tugas('Laporan praktikum PCVK', TaskCategory.kuliah, DateTime(2026, 11, 17, 23, 59),
      start: DateTime(2026, 11, 13), p: Priority.tinggi, group: 'PCVK');
  await tugas('Desain konten kampanye', TaskCategory.kerja, DateTime(2026, 11, 18, 17), start: DateTime(2026, 11, 16));
  await tugas('Proyek akhir: ekstraksi fitur HOG', TaskCategory.kuliah, DateTime(2026, 11, 20, 23, 59),
      start: DateTime(2026, 11, 9), p: Priority.tinggi, group: 'PCVK');
  await tugas('Bayar kos bulan Desember', TaskCategory.pribadi, DateTime(2026, 11, 21, 12), p: Priority.rendah);
  await selesai(
      await tugas('Kuis Basis Data', TaskCategory.kuliah, DateTime(2026, 11, 16, 23, 59)), DateTime(2026, 11, 15, 20));
  await selesai(
      await tugas('Notulen rapat divisi', TaskCategory.kerja, DateTime(2026, 11, 16, 12)), DateTime(2026, 11, 14, 9));
  await selesai(await tugas('Perpanjang SIM', TaskCategory.pribadi, DateTime(2026, 11, 19, 15), p: Priority.rendah),
      DateTime(2026, 11, 15, 11));
  await tugas('Kepanitiaan Dies Natalis', TaskCategory.kerja, DateTime(2026, 11, 28, 17),
      start: DateTime(2026, 11, 19), group: 'Dies Natalis');

  final e = s.events;
  await e.save(
    title: 'Pengolahan Citra dan Visi Komputer',
    type: EventType.kuliah,
    start: DateTime(2026, 9, 7, 7),
    end: DateTime(2026, 9, 7, 9, 30),
    place: 'Lab komputer',
    repeatWeekly: true,
    repeatUntil: DateTime(2026, 12, 31),
  );
  for (final day in [2, 16, 30]) {
    await e.save(
      title: 'Rapat divisi',
      type: EventType.kerja,
      start: DateTime(2026, 11, day, 13),
      end: DateTime(2026, 11, day, 15),
      place: 'Online · Google Meet',
    );
  }
}
