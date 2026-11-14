import 'package:chiko/app/app.dart';
import 'package:chiko/app/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

/// Chiko punya animasi "bernapas" yang terus berjalan, jadi pakai beberapa pump, bukan pumpAndSettle.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<AppServices> mulaiApp(WidgetTester tester, {bool dataContoh = true, bool onboardingSelesai = true}) async {
  // Layar tinggi supaya daftar panjang muat tanpa harus digulir.
  tester.view.physicalSize = const Size(1080, 4400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  final services =
      (await tester.runAsync(() => bukaLayananTest(dataContoh: dataContoh, onboardingSelesai: onboardingSelesai)))!;
  addTearDown(() => tester.runAsync(services.dispose));
  await tester.pumpWidget(ChikoApp(services: services));
  await settle(tester);
  return services;
}

/// Label navigasi bawah selalu yang terakhir di pohon widget (setelah isi halaman).
Future<void> bukaTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await settle(tester);
}

/// Tutup snackbar (bisa menutupi item), pastikan item terlihat, lalu ketuk.
Future<void> ketukItem(WidgetTester tester, Finder finder) async {
  tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first).removeCurrentSnackBar();
  await settle(tester);
  await tester.ensureVisible(finder);
  await settle(tester);
  await tester.tap(finder);
  await settle(tester);
}

Future<void> ketikKeypad(WidgetTester tester, List<String> tombol) async {
  for (final k in tombol) {
    await tester.tap(find.widgetWithText(InkWell, k).first);
    await tester.pump();
  }
}

void main() {
  testWidgets('pertama kali: Sambutan → isi nama → Beranda', (tester) async {
    final app = await mulaiApp(tester, dataContoh: false, onboardingSelesai: false);
    expect(find.text('Halo, aku Chiko!'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Rina');
    await tester.tap(find.text('Mulai'));
    await settle(tester);

    expect(find.text('Halo, Rina!'), findsOneWidget);
    expect(app.settings.onboardingSelesai, isTrue);
    expect(app.settings.namaPengguna, 'Rina');
  });

  testWidgets('sudah pernah buka: langsung ke Beranda', (tester) async {
    await mulaiApp(tester);
    expect(find.text('Halo, aku Chiko!'), findsNothing);
    expect(find.text('Jadwal hari ini'), findsOneWidget);
  });

  testWidgets('Tugas: tambah lewat form, buka & ubah, centang', (tester) async {
    final app = await mulaiApp(tester);
    await bukaTab(tester, 'Tugas');

    await tester.tap(find.byTooltip('Tambah tugas'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Misal: Laporan Praktikum PCVK'), 'Resume jurnal');
    await tester.tap(find.text('Simpan Tugas'));
    await settle(tester);
    expect(app.tasks.all.any((t) => t.title == 'Resume jurnal'), isTrue);
    expect(find.text('Resume jurnal'), findsOneWidget);

    // Ketuk kartu → form ubah (bukan mencentang).
    await ketukItem(tester, find.text('Resume jurnal'));
    expect(find.text('Ubah Tugas'), findsOneWidget);
    expect(app.tasks.all.firstWhere((t) => t.title == 'Resume jurnal').done, isFalse);
    await tester.enterText(find.widgetWithText(TextField, 'Resume jurnal'), 'Resume jurnal AI');
    await tester.tap(find.text('Simpan Perubahan'));
    await settle(tester);
    expect(find.text('Resume jurnal AI'), findsOneWidget);

    // Kotak centang → selesai.
    final tile = find.ancestor(of: find.text('Resume jurnal AI'), matching: find.byType(InkWell)).first;
    await ketukItem(tester, find.descendant(of: tile, matching: find.byType(Checkbox)));
    expect(app.tasks.all.firstWhere((t) => t.title == 'Resume jurnal AI').done, isTrue);
  });

  testWidgets('Keuangan: catat pengeluaran dengan keypad, lalu buka & hapus', (tester) async {
    final app = await mulaiApp(tester);
    await bukaTab(tester, 'Keuangan');
    final dompet = app.finance.accounts.firstWhere((a) => a.name == 'Dompet').id;
    final saldoAwal = app.finance.balanceOf(dompet);

    await tester.tap(find.byTooltip('Tambah transaksi'));
    await settle(tester);
    await ketikKeypad(tester, ['1', '2', '000']);
    expect(find.text('Rp 12.000'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Fotokopi');
    await tester.tap(find.text('Simpan pengeluaran'));
    await settle(tester);
    expect(app.finance.balanceOf(dompet), saldoAwal - 12000);
    expect(find.text('Fotokopi'), findsOneWidget);

    await ketukItem(tester, find.text('Fotokopi'));
    expect(find.text('Ubah transaksi'), findsOneWidget);
    await tester.tap(find.byTooltip('Hapus transaksi'));
    await settle(tester);
    expect(app.finance.balanceOf(dompet), saldoAwal);
    expect(find.text('Fotokopi'), findsNothing);
  });

  testWidgets('Keuangan: pengeluaran melebihi saldo ditolak dengan pesan', (tester) async {
    final app = await mulaiApp(tester);
    await bukaTab(tester, 'Keuangan');
    final jumlah = app.finance.byDayInMonth(jamTest).expand((d) => d.$2).length;
    await tester.tap(find.byTooltip('Tambah transaksi'));
    await settle(tester);
    await ketikKeypad(tester, ['9', '000', '000']);
    await tester.tap(find.text('Simpan pengeluaran'));
    await settle(tester);
    expect(find.textContaining('tidak cukup'), findsOneWidget);
    expect(app.finance.byDayInMonth(jamTest).expand((d) => d.$2), hasLength(jumlah));
  });

  testWidgets('Kalender: blok proyek tampil dan agenda bisa dibuka', (tester) async {
    await mulaiApp(tester);
    await bukaTab(tester, 'Kalender');
    expect(find.textContaining('Proyek akhir: ekstraksi fitur HOG'), findsWidgets);
    expect(find.text('PROYEK BERJALAN'), findsOneWidget);

    await ketukItem(tester, find.text('Pengolahan Citra dan Visi Komputer'));
    expect(find.text('Ubah Jadwal'), findsOneWidget);
  });

  testWidgets('Pengaturan: tambah akun baru', (tester) async {
    final app = await mulaiApp(tester);
    await bukaTab(tester, 'Pengaturan');
    expect(find.text('Notifikasi pengingat'), findsNothing, reason: 'fitur palsu sudah dihapus');

    await tester.tap(find.text('Kelola akun'));
    await settle(tester);
    await tester.tap(find.byTooltip('Tambah akun'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Misal: BRI, GoPay, Dompet'), 'GoPay');
    await tester.enterText(find.widgetWithText(TextField, '0'), '75000');
    await tester.tap(find.text('Simpan Akun'));
    await settle(tester);
    final gopay = app.finance.accounts.firstWhere((a) => a.name == 'GoPay');
    expect(app.finance.balanceOf(gopay.id), 75000);
  });
}
