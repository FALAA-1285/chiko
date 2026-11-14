// Uji ujung-ke-ujung di perangkat/desktop sungguhan:
//   flutter test integration_test -d windows   (atau -d <id HP Android>)
//
// Memakai file database sementara (bukan data aplikasi asli) dan jam sungguhan.
import 'dart:io';

import 'package:chiko/app/app.dart';
import 'package:chiko/app/app_scope.dart';
import 'package:chiko/core/data/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pengguna baru: sambutan → tambah tugas → buka ulang app, data masih ada', (tester) async {
    final dir = await Directory.systemTemp.createTemp('chiko_it');
    final file = File('${dir.path}/chiko.sqlite');
    addTearDown(() => dir.delete(recursive: true));

    // ---- Sesi pertama
    var services = await AppServices.open(AppDatabase(NativeDatabase(file)));
    await tester.pumpWidget(ChikoApp(key: UniqueKey(), services: services));
    await settle(tester);

    expect(find.text('Halo, aku Chiko!'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Uji');
    await tester.tap(find.text('Mulai'));
    await settle(tester);
    expect(find.text('Halo, Uji!'), findsOneWidget);

    await tester.tap(find.text('Tugas').last);
    await settle(tester);
    await tester.tap(find.byTooltip('Tambah tugas'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Misal: Laporan Praktikum PCVK'), 'Tugas integrasi');
    await tester.tap(find.text('Simpan Tugas'));
    await settle(tester);
    expect(find.text('Tugas integrasi'), findsOneWidget);

    // ---- "Tutup" app lalu buka lagi dari file yang sama
    await tester.pumpWidget(const SizedBox());
    await services.dispose();
    services = await AppServices.open(AppDatabase(NativeDatabase(file)));
    addTearDown(services.dispose);
    await tester.pumpWidget(ChikoApp(key: UniqueKey(), services: services));
    await settle(tester);

    expect(find.text('Halo, aku Chiko!'), findsNothing, reason: 'sambutan tidak muncul lagi');
    expect(find.text('Halo, Uji!'), findsOneWidget);
    await tester.tap(find.text('Tugas').last);
    await settle(tester);
    expect(find.text('Tugas integrasi'), findsOneWidget);
  });
}
