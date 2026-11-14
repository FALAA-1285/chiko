import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chiko/app/app.dart';
import 'package:chiko/app/router.dart';

void main() {
  testWidgets('ChikoApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ChikoApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Mulai to go to /beranda
    await tester.tap(find.text('Mulai'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Jadwal hari ini'), findsOneWidget);

    // Tap Keuangan nav tab
    await tester.tap(find.text('Keuangan').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Total saldo'), findsOneWidget);
    expect(find.text('Transaksi terakhir'), findsOneWidget);
  });
}
