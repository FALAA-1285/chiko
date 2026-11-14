import 'dart:io';

import 'package:chiko/app/app_scope.dart';
import 'package:chiko/core/data/app_database.dart';
import 'package:chiko/core/data/aturan_error.dart';
import 'package:chiko/core/mascot/chiko.dart';
import 'package:chiko/core/utils/formatters.dart';
import 'package:chiko/features/calendar/data/event_store.dart';
import 'package:chiko/features/calendar/data/span_layout.dart';
import 'package:chiko/features/dashboard/chiko_mood.dart';
import 'package:chiko/features/finance/data/finance_store.dart';
import 'package:chiko/features/tasks/data/task_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

final throwsAturan = throwsA(isA<AturanError>());

void main() {
  final now = jamTest; // Senin, 16 Nov 2026 10.00
  late AppServices app;

  setUp(() async => app = await bukaLayananTest());
  tearDown(() => app.dispose());

  group('formatters', () {
    test('rupiah menampilkan tanda minus', () {
      expect(rupiah(1250000), 'Rp 1.250.000');
      expect(rupiah(-5000), '-Rp 5.000');
      expect(rupiah(0), 'Rp 0');
    });

    test('rupiahSingkat', () {
      expect(rupiahSingkat(45000), '45rb');
      expect(rupiahSingkat(1500000), '1,5jt');
      expect(rupiahSingkat(100000000), '100jt');
      expect(rupiahSingkat(-45000), '-45rb');
    });

    test('selisihHari, awalMinggu, rentangTanggal', () {
      expect(selisihHari(now, DateTime(2026, 11, 17, 0, 1)), 1);
      expect(selisihHari(now, DateTime(2026, 11, 15, 23, 59)), -1);
      expect(awalMinggu(DateTime(2026, 11, 22)), DateTime(2026, 11, 16));
      expect(rentangTanggal(DateTime(2026, 11, 9), DateTime(2026, 11, 20)), '9–20 Nov');
      expect(rentangTanggal(DateTime(2026, 10, 28), DateTime(2026, 11, 3)), '28 Okt – 3 Nov');
    });
  });

  group('penyimpanan', () {
    test('database baru berisi kategori & akun bawaan', () async {
      final kosong = await bukaLayananTest(dataContoh: false);
      addTearDown(kosong.dispose);
      expect(kosong.finance.accounts.map((a) => a.name), ['Dompet']);
      expect(kosong.finance.categoriesFor(TxnKind.expense), isNotEmpty);
      expect(kosong.finance.categoriesFor(TxnKind.income), isNotEmpty);
      expect(kosong.tasks.all, isEmpty);
      // Pengguna baru (Dompet Rp 0, belum ada transaksi) tidak langsung diperingatkan saldo menipis.
      expect(hitungMood(now: now, tasks: kosong.tasks, finance: kosong.finance).mood, isNot(ChikoMood.kaget));
    });

    test('data tetap ada setelah database ditutup dan dibuka lagi', () async {
      final dir = await Directory.systemTemp.createTemp('chiko_test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/chiko.sqlite');

      final pertama = await AppServices.open(AppDatabase(NativeDatabase(file)));
      await pertama.tasks.add(title: 'Tugas tersimpan', category: TaskCategory.kuliah, dueAt: DateTime(2026, 12, 1));
      await pertama.settings.setNamaPengguna('Ahmad');
      await pertama.settings.selesaikanOnboarding();
      await pertama.dispose();

      final kedua = await AppServices.open(AppDatabase(NativeDatabase(file)));
      addTearDown(kedua.dispose);
      expect(kedua.tasks.all.map((t) => t.title), ['Tugas tersimpan']);
      expect(kedua.settings.namaPengguna, 'Ahmad');
      expect(kedua.settings.onboardingSelesai, isTrue);
      expect(kedua.finance.accounts, hasLength(1), reason: 'data bawaan tidak diisi ulang saat dibuka lagi');
    });
  });

  group('tugas', () {
    test('terlambat bila jam deadline sudah lewat', () {
      final t = Task(id: 1, title: 'x', category: TaskCategory.kuliah, dueAt: DateTime(2026, 11, 16, 9));
      expect(t.isOverdue(now), isTrue);
      expect(t.isUrgent(now), isTrue);
      expect(t.copyWith(completedAt: () => now).isOverdue(now), isFalse);
    });

    test('tambah: judul kosong, deadline lewat, atau mulai setelah deadline ditolak', () {
      final s = app.tasks;
      expect(s.add(title: '  ', category: TaskCategory.kuliah, dueAt: DateTime(2026, 12, 1)), throwsAturan);
      expect(s.add(title: 'x', category: TaskCategory.kuliah, dueAt: DateTime(2026, 11, 16, 9)), throwsAturan);
      expect(
        s.add(title: 'x', category: TaskCategory.kuliah, startAt: DateTime(2026, 12, 5), dueAt: DateTime(2026, 12, 1)),
        throwsAturan,
      );
    });

    test('ubah, centang, hapus lalu batal', () async {
      final s = app.tasks;
      final t = s.active.firstWhere((t) => t.title == 'Bayar kos bulan Desember');
      await s.update(t.copyWith(title: 'Bayar kos Desember', priority: Priority.tinggi));
      final diubah = s.byId(t.id)!;
      expect((diubah.title, diubah.priority), ('Bayar kos Desember', Priority.tinggi));

      await s.toggle(diubah);
      expect(s.byId(t.id)!.completedAt, now);
      await s.toggle(diubah);
      expect(s.byId(t.id)!.done, isFalse);

      final jumlah = s.all.length;
      final terakhir = s.byId(t.id)!;
      await s.remove(terakhir);
      expect(s.byId(t.id), isNull);
      await s.restore(terakhir);
      expect(s.all, hasLength(jumlah));
      expect(s.byId(t.id)!.title, 'Bayar kos Desember');
    });

    test('Chiko kaget bila ada tugas terlambat', () async {
      await app.tasks.add(
        title: 'Tugas telat',
        category: TaskCategory.kuliah,
        dueAt: DateTime(2026, 11, 15, 12),
        requireFutureDeadline: false,
      );
      final status = hitungMood(now: now, tasks: app.tasks, finance: app.finance);
      expect(status.mood, ChikoMood.kaget);
      expect(status.message, contains('lewat deadline'));
    });
  });

  group('keuangan', () {
    int akun(String nama) => app.finance.accounts.firstWhere((a) => a.name == nama).id;
    int kat(String nama, [TxnKind kind = TxnKind.expense]) =>
        app.finance.categories.firstWhere((c) => c.name == nama && c.kind == kind).id;
    Txn txnDengan(String note) => app.finance.byDayInMonth(now).expand((d) => d.$2).firstWhere((t) => t.note == note);

    String? cek({
      TxnKind kind = TxnKind.expense,
      int amount = 10000,
      String from = 'Dompet',
      String? to,
      int? cat,
      DateTime? date,
      int? editingId,
    }) =>
        app.finance.validate(
          kind: kind,
          amount: amount,
          accountId: akun(from),
          toAccountId: to == null ? null : akun(to),
          categoryId:
              kind == TxnKind.transfer ? null : (cat ?? kat(kind == TxnKind.income ? 'Uang saku' : 'Makan', kind)),
          date: date ?? now,
          now: now,
          editingId: editingId,
        );

    test('saldo dihitung dari saldo awal dan transaksi', () {
      expect(app.finance.balanceOf(akun('Dompet')), 150000);
      expect(app.finance.balanceOf(akun('BTN')), 1295000);
      expect(app.finance.balanceOf(akun('BRI')), 270000);
      expect(app.finance.totalBalance, 1715000);
    });

    test('aturan transaksi', () {
      expect(cek(), isNull);
      expect(cek(amount: 0), isNotNull);
      expect(cek(amount: 150001), contains('tidak cukup'));
      expect(cek(kind: TxnKind.transfer, from: 'BRI', to: 'BRI'), isNotNull);
      expect(cek(kind: TxnKind.transfer, from: 'BRI', to: 'Dompet'), isNull);
      expect(cek(kind: TxnKind.income, cat: kat('Makan')), isNotNull, reason: 'kategori pengeluaran untuk pemasukan');
      expect(cek(date: now.add(const Duration(days: 1))), isNotNull);
    });

    test('mengedit transaksi tidak menghitung nominal lamanya sendiri', () async {
      final f = app.finance;
      final siang = txnDengan('Makan siang');
      // Saldo Dompet 150rb; transaksi 25rb ini boleh dinaikkan sampai 175rb.
      expect(cek(amount: 175000, editingId: siang.id), isNull);
      expect(cek(amount: 175001, editingId: siang.id), contains('tidak cukup'));
      await f.saveTxn(
        kind: TxnKind.expense,
        amount: 30000,
        accountId: siang.accountId,
        categoryId: siang.categoryId,
        date: siang.date,
        now: now,
        editingId: siang.id,
      );
      expect(f.txnById(siang.id)!.amount, 30000);
      expect(f.balanceOf(akun('Dompet')), 145000);
    });

    test('hapus transaksi lalu batal', () async {
      final f = app.finance;
      final siang = txnDengan('Makan siang');
      await f.deleteTxn(siang);
      expect(f.balanceOf(akun('Dompet')), 175000);
      await f.restoreTxn(siang);
      expect(f.balanceOf(akun('Dompet')), 150000);
    });

    test('menghapus pemasukan yang uangnya sudah terpakai ditolak', () {
      // BTN 1.295.000 - 1.500.000 < 0
      expect(app.finance.deleteTxn(txnDengan('Uang saku')), throwsAturan);
    });

    test('akun: nama kembar, hapus akun terpakai, saldo awal yang membuat minus ditolak', () async {
      final f = app.finance;
      expect(f.saveAccount(name: 'bri', type: AccountType.bank, initialBalance: 0, colorValue: 0), throwsAturan);
      expect(f.deleteAccount(f.accountById(akun('BRI'))!), throwsAturan);
      // BTN: saldo awal 300rb, saldo sekarang 1.295.000 → saldo awal 0 masih aman.
      await f.saveAccount(
          name: 'BTN', type: AccountType.bank, initialBalance: 0, colorValue: 0, editingId: akun('BTN'));
      expect(f.balanceOf(akun('BTN')), 995000);
      // Dompet: tanpa saldo awal 50rb, saldo jadi 100rb — masih aman. Uji batas dengan pengeluaran besar.
      await f.saveTxn(
        kind: TxnKind.expense,
        amount: 150000,
        accountId: akun('Dompet'),
        categoryId: kat('Makan'),
        date: now,
        now: now,
      );
      expect(
        f.saveAccount(
            name: 'Dompet', type: AccountType.cash, initialBalance: 0, colorValue: 0, editingId: akun('Dompet')),
        throwsAturan,
      );

      await f.saveAccount(name: 'GoPay', type: AccountType.ewallet, initialBalance: 0, colorValue: 0);
      await f.deleteAccount(f.accountById(akun('GoPay'))!);
      expect(f.accounts.map((a) => a.name), isNot(contains('GoPay')));
    });

    test('kategori: tambah, ubah, hapus yang tidak dipakai; yang dipakai ditolak', () async {
      final f = app.finance;
      await f.saveCategory(name: 'Kos', kind: TxnKind.expense, iconKey: 'rumah', paletIndex: 1);
      final kos = f.categoriesFor(TxnKind.expense).firstWhere((c) => c.name == 'Kos');
      await f.saveCategory(
          name: 'Kos & listrik', kind: TxnKind.expense, iconKey: 'tagihan', paletIndex: 2, editingId: kos.id);
      expect(f.categoryById(kos.id)!.name, 'Kos & listrik');
      await f.deleteCategory(f.categoryById(kos.id)!);
      expect(f.categoryById(kos.id), isNull);
      expect(f.deleteCategory(f.categoryById(kat('Makan'))!), throwsAturan);
    });

    test('transaksi per bulan', () {
      final hari = app.finance.byDayInMonth(DateTime(2026, 11));
      expect(hari.first.$1, DateTime(2026, 11, 16));
      expect(hari.expand((d) => d.$2), hasLength(15));
      expect(app.finance.byDayInMonth(DateTime(2026, 10)), isEmpty);
    });
  });

  group('jadwal', () {
    test('jam selesai harus setelah jam mulai', () {
      expect(
        app.events.save(
            title: 'Rapat', type: EventType.kerja, start: DateTime(2026, 11, 20, 10), end: DateTime(2026, 11, 20, 9)),
        throwsAturan,
      );
    });

    test('berulang mingguan sampai tanggal tertentu, bisa diubah dan dihapus', () async {
      final e = app.events;
      final kuliah = e.scheduleOn(now).firstWhere((x) => x.title.startsWith('Pengolahan Citra'));
      expect(e.scheduleOn(DateTime(2026, 11, 23)).any((x) => x.entryId == kuliah.entryId), isTrue);
      expect(e.scheduleOn(DateTime(2027, 1, 4)).any((x) => x.entryId == kuliah.entryId), isFalse);

      final entry = e.byId(kuliah.entryId!)!;
      await e.save(
        title: entry.title,
        type: entry.type,
        start: entry.start,
        end: entry.end,
        repeatWeekly: true,
        repeatUntil: DateTime(2026, 11, 20),
        editingId: entry.id,
      );
      expect(e.scheduleOn(DateTime(2026, 11, 23)).any((x) => x.entryId == entry.id), isFalse);

      await e.remove(e.byId(entry.id)!);
      expect(e.byId(entry.id), isNull);
    });

    test('agenda menggabungkan jadwal dan deadline tugas', () {
      final agenda = app.events.agendaOn(DateTime(2026, 11, 17));
      expect(agenda.where((a) => a.type == EventType.deadline).map((a) => a.title), contains('Laporan praktikum PCVK'));
    });
  });

  group('rentang proyek (blok kalender)', () {
    Task span(int id, DateTime start, DateTime due) =>
        Task(id: id, title: 'P$id', category: TaskCategory.kerja, startAt: start, dueAt: due);

    test('durasi dan spans()', () {
      final t = span(1, DateTime(2026, 11, 9), DateTime(2026, 11, 20, 23, 59));
      expect(t.durasiHari, 12);
      expect(t.spans(DateTime(2026, 11, 20, 23)), isTrue);
      expect(t.spans(DateTime(2026, 11, 21)), isFalse);
    });

    test('blok dipotong per minggu dan diberi tanda bersambung', () {
      final minggu = DateTime(2026, 11, 16);
      final bar = layoutWeek(minggu, [span(1, DateTime(2026, 11, 9), DateTime(2026, 11, 28, 17))]).single;
      expect((bar.startCol, bar.endCol, bar.continuesLeft, bar.continuesRight), (0, 6, true, true));
      final pendek = layoutWeek(minggu, [span(2, DateTime(2026, 11, 17), DateTime(2026, 11, 19))]).single;
      expect((pendek.startCol, pendek.endCol, pendek.continuesLeft, pendek.continuesRight), (1, 3, false, false));
    });

    test('blok bertumpuk pindah lajur; yang bersambung didahulukan', () {
      final minggu = DateTime(2026, 11, 16);
      final bars = layoutWeek(minggu, [
        span(1, DateTime(2026, 11, 16), DateTime(2026, 11, 18)),
        span(2, DateTime(2026, 11, 17), DateTime(2026, 11, 20)),
        span(3, DateTime(2026, 11, 19), DateTime(2026, 11, 22)),
        span(4, DateTime(2026, 11, 12), DateTime(2026, 11, 16)),
      ]);
      int laneOf(int id) => bars.firstWhere((b) => b.task.id == id).lane;
      expect(laneOf(4), 0, reason: 'bersambung dari minggu lalu → lajur atas (hanya Senin)');
      expect(laneOf(1), 1, reason: 'Sen–Rab bertumpuk dengan P4 di Senin');
      expect(laneOf(2), 0, reason: 'Sel–Jum muat di lajur 0 setelah P4 selesai');
      expect(laneOf(3), 1, reason: 'Kam–Min muat di lajur 1 setelah P1 selesai');
    });

    test('store: tugas berentang yang berjalan di suatu hari', () {
      final berjalan = app.tasks.spanningOn(DateTime(2026, 11, 16));
      expect(
          berjalan.map((t) => t.title), containsAll(['Proyek akhir: ekstraksi fitur HOG', 'Laporan praktikum PCVK']));
    });
  });
}
